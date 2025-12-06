#0.ai解释

```
这段代码是 MySQL 元数据锁（MDL）系统的核心实现部分。以下是详细解释：

核心数据结构
1. Ticket_list 类 (票证列表)
用于管理某个锁的所有获得者或等待者，同时维护一个位图来快速判断特定类型的锁是否存在。

2. MDL_lock_strategy 结构 (锁策略)
定义了如何处理不同类型的锁：

字段	含义
m_granted_incompatible	位图数组，指定哪些已获得的锁与请求的锁不兼容
m_waiting_incompatible[4]	4 个优先级矩阵，定义等待锁之间的优先级关系
m_unobtrusive_lock_increment	"不明显"锁类型的增量（用于快速路径优化）
m_is_affected_by_max_write_lock_count	该锁类型是否受 max_write_lock_count 限制
函数指针	通知、连接检查等回调函数
3. MDL_lock 类 (锁对象)
这是真正的元数据锁对象，主要成员包括：

关键成员变量：
成员	用途
key	被锁保护的对象的键（如表名、数据库名）
m_rwlock	读写锁，保护此锁上下文
m_granted	已获得的票证列表
m_waiting	等待的票证列表
m_hog_lock_count	"猪" 类型锁（X、SNRW、SNW）连续授予的次数
m_piglet_lock_count	"小猪" 类型锁（SW）连续授予的次数
m_fast_path_state	快速路径锁的状态 (64位整数，打包了多个信息)
关键标志位：
核心概念解析
1. "Unobtrusive" vs "Obtrusive" 锁 (不明显 vs 显眼锁)
不明显锁（Unobtrusive）：

与同类型锁兼容
常见于 DML 操作（SELECT、INSERT、UPDATE）
使用"快速路径"优化，避免复杂的位图操作
通过整数计数器来跟踪（性能优化）
显眼锁（Obtrusive）：

与某些其他锁类型或自身不兼容
不常见，如 DDL 操作
必须使用"慢速路径"，需要操作位图和列表
2. "Fast Path" vs "Slow Path" (快速 vs 慢速路径)
快速路径减少了持锁时间，提高了并发性能。

3. 防止饥饿的机制 (Starvation Prevention)
这确保了低优先级的锁不会被高优先级的锁无限期地饿死。

4. 原子操作包装 (Atomic Operation Wrappers)
这些方法确保在多线程环境下的安全性和一致性。

主要方法
方法	功能
can_grant_lock()	判断是否可以授予锁
has_pending_conflicting_lock()	检查是否有冲突的待处理锁
count_piglets_and_hogs()	统计高优先级锁的连续授予次数
reschedule_waiters()	重新调度等待的锁请求
visit_subgraph()	用于死锁检测的图遍历
使用场景示例
当执行 SELECT * FROM users; 时：

获取表 users 的 SR（MDL_SHARED_READ）锁
因为 SR 是"不明显"锁，使用快速路径
m_fast_path_state 中的相应计数器递增
无需操作 m_granted 链表（性能优化）
这个设计使 MySQL 能够在高并发场景下高效地管理元数据锁。
```


#1.notes

```cpp
/**
The lock context. Created internally for an acquired lock.
 For a given name, there exists only one MDL_lock instance,and it exists only
 when the lock has been granted.
Can be seen as an MDL subsystem's version of TABLE_SHARE.  //能够被存储层的TABLE_
SHARE使用这个锁对象
This is an abstract class which lacks information about compatibility rules for lock types.
 They should be specifiedin its descendants.
*/
class MDL_lock  //当需要施加元数据锁的时候，生成一个MDL_lock锁对象
{...
    class Ticket_list{...}  
    //把MDL_ticket封装为一个 List对象，用以存放多个MDL_ticket锁对象（MDL_ticket参见下一小节）
    /**  
    //对于锁的操作，又存在两种策略，这是根据被加锁的对象的特定区分的。每一种策略分别有各
    自的锁兼容规则
      Helper struct which defines how different types of locks are handledfor a
      specific MDL_lock.
      In practice we use only two strategies:
      "scoped"lock strategy for locks in GLOBAL, COMMIT, TABLESPACE and SCHEMA
       namespaces  //范围锁策略：范围带有空间的意味
      and "object" lock strategy for all other namespaces.
                                 //对象锁策略：数据库内部的各种对象
     */
    struct MDL_lock_strategy 
    //锁的施加策略。如上所述，锁被分为两种类型，所以统一用策略数据结构来管理和描述这两类锁的特性
    {
        /**Compatibility (or rather "incompatibility") matrices for lock types.
         //新申请的锁向已经授予的锁进行锁的相容性判断
            Array of bitmaps which elements specify which granted locks
            areincompatible with the type of lock being requested.*/
        bitmap_tm_granted_incompatible[MDL_TYPE_END];  
        //已经被授予的锁的数组中保存有不兼容的、准备申请此对象的请求锁，位图数组结构
        //新申请的锁向已经正在等待的锁进行锁的相容性（优先级）判断。此数组的作用有两个：
        //一是通过m_waiting_incompatible[0]，
        //二是防止产生锁饥饿现象，
        //所以增加了对低优先级锁的申请次数的计数，当计数到一定程度时，唤醒低优先级的尚没获得锁的会话。
        //可以关注MDL_lock::reschedule_waiters()函数，查看对等待的锁的处理方式；看其调用者查看唤醒条件。
        //另外看此函数中封锁粒度较强的锁释放而封锁粒度较弱的锁得以有机会被授予的时候，
        //m_hog_lock_count/m_piglet_lock_count有机会被重置
        //（注意强弱是相对的，取决于11.4.1节中第3小节中定义的enum_mdl_type中的锁的粒度值，据这些值比较大小）
         /** Arrays of bitmaps which elements specify which waiting locks
           areincompatible with the type of lock being requested.
             Basically, eacharray defines priorities between lock types.
            We need 4 separate arrays since in order to prevent starvation for
            some of lock request types, we use different priority matrices:
          0) in "normal" situation.  //正常优先级
          1) in situation when the number of successively granted "piglet"
             requests exceeds the max_write_lock_count limit. //小猪优先级
          2) in situation when the number of successively granted "hog"
             request sexceeds the max_write_lock_count limit. //猪优先级
          3) in situation when both "piglet" and "hog" counters exceed limit.*/
            //小猪和猪之和
        //这个矩阵是某个锁请求与处于等待状态的锁的优先级比较表
        //第一个数组是正常情况，其他三个数组是为解决锁饥饿而设置的
        //如m_piglet_lock_count的值大于了max_write_lock_count，则m_waiting_
          incompatible[1][x]被置位
        //如m_hog_lock_count的值大于了max_write_lock_count，则m_waiting_
          incompatible[2][x]被置位
        //在等待的锁的数组中保存有不兼容的、准备申请此对象的请求锁，二维位图数组结构
        bitmap_tm_waiting_incompatible[4][MDL_TYPE_END];//piglet，会申请SW锁；hog，
        会申请X、SNRW、SNW这三者其一
        /**Array of increments for "unobtrusive" types of lock requests for locks.
           @sa MDL_lock::get_unobtrusive_lock_increment().*/
        //“unobtrusive”类型相关的锁粒度包括： S、SH、SR 和SW，对应“Fast path”的访问方
           式，主要用于DML类操作
        //“obtrusive” 类型相关的锁粒度包括：SU、SRO、SNW、SNRW、X，对应“slow path”的
           访问方式，主要用于非DML类操作
        fast_path_state_tm_unobtrusive_lock_increment[MDL_TYPE_END];
        //快速访问“unobtrusive”类型的锁
        /**Indicates that locks of this type are affected bythe max_write_lock_count limit.*/
        bool m_is_affected_by_max_write_lock_count;
        /**Pointer to a static method which determines if the type of
          lockrequested requires notification of conflicting locks.
           NULL if thereare no lock types requiring notification.*/
        //当有冲突锁的时候，是否要被通知。“scopedlock”不要求被通知，而“object lock”施
          加排它锁时才需要被通知
        bool (*m_needs_notification)(const MDL_ticket *ticket);
        /**Pointer to a static method which allows notification of owners
         ofconflicting locksabout the fact
           that a type of lock requiringnotification was requested.*/
        //对于“object lock”，通知持有S、SH类锁的会话线程（可能与待定的X锁冲突，pending lock）
        void (*m_notify_conflicting_locks)(MDL_context *ctx, MDL_lock *lock);
        //发出通知的函数，含义类似上面
        /**Pointer to a static method which converts information aboutlocks
          granted using "fast" path
           from fast_path_state_trepresentation to bitmap of lock types.*/
        //S、SR、SW粒度的锁可以被使用“fast path”方式快速处理
        bitmap_t (*m_fast_path_granted_bitmap)(const MDL_lock &lock);
         /**Pointer to a static method which determines if waiting for the
          lockshould be aborted
           when connection is lost. NULL if locks ofthis type don't require such
           aborts.*/ //当连接断开的时候，锁是否应该被撤销。
        //LOCKING_SERVICE和USER_LEVEL_LOCK加锁的情况可被撤销，如通过GET_LOCK()施加的锁。
        bool (*m_needs_connection_check)(const MDL_lock *lock);
    };
public:
    /** The key of the object (data) being protected. */
     MDL_key key;   //元数据锁所属的类型（在MDL_key中把元数据这样的对象分为了几类，给每类定
     义一个key在enum_mdl_namespace枚举中）
…
    /** List of granted tickets for this lock. */
    Ticket_list m_granted;  //对于本锁而言，在系统内部存在的已经被授予的所有锁list
    /** Tickets for contexts waiting to acquire a lock. */
Ticket_list m_waiting; //对于本锁而言，在系统内部存在的正在等待被授予的所有锁list
//如上两个list，配合使用：
//当要获取一个锁（入通过acquire_lock()函数）不成功时，把新生成的一个MDL_ticket对象放入等待
队列；获取成功，则放入m_granted中
//当一个处于等待状态的锁可以被授予的时候（can_grant_lock()判断是否可以被授予），就从m_
waiting中remove掉，然后加入到m_granted中，
//这样的事情，当获取锁或释放锁时，或因ALTER TABLE等操作需要降级锁时，通过reschedule_
waiters()函数进行
...
    /** Pointer to strategy object which defines how different types of lock
        requests should be handled for the namespace to which this lock belongs.
        @sa MDL_lock::m_scoped_lock_strategy and MDL_lock:m_object_lock_strategy. */
    const MDL_lock_strategy *m_strategy; //注意这是一个指针，执行哪个类型的策略就表示使
    用被指向的策略对象之策略（指向下面两个策略对象之一）
...
    static const MDL_lock_strategy m_scoped_lock_strategy; //范围锁对应的策略
    static const MDL_lock_strategy m_object_lock_strategy; //对象锁对应的策略
};
```





#2.class MDL_lock

```cpp
/*
　　mdl_lock表示系统的一个mdl锁，所有的mdl request都请求对应的mdl_lock，这个mdl_lock结构保存了两个queue，
　　一个是grant_queue表示拿到lock的请求队列。
　　一个是wait_queue表示请求这个mdl_lock的阻塞队列。
*/
/**
  The lock context. Created internally for an acquired lock.
  For a given name, there exists only one MDL_lock instance,
  and it exists only when the lock has been granted.
  Can be seen as an MDL subsystem's version of TABLE_SHARE.

  This is an abstract class which lacks information about
  compatibility rules for lock types. They should be specified
  in its descendants.
*/

class MDL_lock
{
public:
  /** The key of the object (data) being protected. */
  MDL_key key;
  
  mysql_prlock_t m_rwlock;  
  /** List of granted tickets for this lock. */
  Ticket_list m_granted;
  /** Tickets for contexts waiting to acquire a lock. */
  Ticket_list m_waiting;

private:
  /**
    Number of times high priority, "hog" lock requests (X, SNRW, SNW) have been
    granted while lower priority lock requests (all other types) were waiting.
    Currently used only for object locks. Protected by m_rwlock lock.
  */
  ulong m_hog_lock_count;
  /**
    Number of times high priority, "piglet" lock requests (SW) have been
    granted while locks requests with lower priority (SRO) were waiting.
    Currently used only for object locks. Protected by m_rwlock lock.
  */
  ulong m_piglet_lock_count;
  /**
    Index of one of the MDL_lock_strategy::m_waiting_incompatible
    arrays which represents the current priority matrice.
  */
  uint m_current_waiting_incompatible_idx;
public:
  /**
    Number of granted or waiting lock requests of "obtrusive" type.
    Also includes "obtrusive" lock requests for which we about to check
    if they can be granted.


    @sa MDL_lock::get_unobtrusive_lock_increment() description.

    @note This number doesn't include "unobtrusive" locks which were acquired
          using "slow path".
  */
  uint m_obtrusive_locks_granted_waiting_count;
  /**
    Combination of IS_DESTROYED/HAS_OBTRUSIVE/HAS_SLOW_PATH flags and packed
    counters of specific types of "unobtrusive" locks which were granted using
    "fast path".

    @sa MDL_scoped_lock::m_unobtrusive_lock_increment and
        MDL_object_lock::m_unobtrusive_lock_increment for details about how
        counts of different types of locks are packed into this field.

    @note Doesn't include "unobtrusive" locks granted using "slow path".

    @note We use combination of atomic operations and protection by
          MDL_lock::m_rwlock lock to work with this member:

          * Write and Read-Modify-Write operations are always carried out
            atomically. This is necessary to avoid lost updates on 32-bit
            platforms among other things.
          * In some cases Reads can be done non-atomically because we don't
            really care about value which they will return (for example,
            if further down the line there will be an atomic compare-and-swap
            operation, which will validate this value and provide the correct
            value if the validation will fail).
          * In other cases Reads can be done non-atomically since they happen
            under protection of MDL_lock::m_rwlock and there is some invariant
            which ensures that concurrent updates of the m_fast_path_state
            member can't happen while  MDL_lock::m_rwlock is held
            (@sa IS_DESTROYED, HAS_OBTRUSIVE, HAS_SLOW_PATH).

    @note IMPORTANT!!!
          In order to enforce the above rules and other invariants,
          MDL_lock::m_fast_path_state should not be updated directly.
          Use fast_path_state_cas()/add()/reset() wrapper methods instead.

    @note Needs to be volatile in order to be compatible with our
          my_atomic_*() API.
  */
  volatile fast_path_state_t m_fast_path_state;
  
  static const MDL_lock_strategy m_scoped_lock_strategy;
  static const MDL_lock_strategy m_object_lock_strategy;
};        
```