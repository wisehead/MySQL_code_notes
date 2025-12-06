#1.AI notes

```cpp
这段代码定义了 MDL_context 类，是 MySQL 元数据锁系统中每个连接的锁上下文。以下是详细解释：

核心概念
MDL_context 代表一个服务器连接在元数据锁系统中的上下文，管理该连接持有的所有锁。

关键数据结构
1. 三级票证列表
这三种锁的用途：

锁类型	释放时机	用途
STATEMENT	语句结束	SELECT、INSERT、UPDATE、DELETE 等 DML
TRANSACTION	事务结束	跨越多个语句的锁
EXPLICIT	手动释放	LOCK TABLES、GET_LOCK() 等
重要特性：statement/transaction 锁按反向时间顺序存储（最新的在前），便于 ROLLBACK TO SAVEPOINT。

2. 核心成员变量
成员	类型	用途
m_owner	MDL_context_owner*	指向连接的 THD（Thread Handler）对象
m_wait	MDL_wait	等待条件变量和状态
m_needs_thr_lock_abort	bool	是否需要中止表级锁等待（避免死锁）
m_force_dml_deadlock_weight	bool	强制使用 DML 权重进行死锁检测
m_LOCK_waiting_for	mysql_prlock_t	保护 m_waiting_for 的读写锁
m_waiting_for	MDL_wait_for_subgraph*	当前等待的锁（用于死锁检测）
m_pins	LF_PINS*	无锁哈希表的 hazard pointers
m_rand_state	uint	伪随机数生成器状态
主要方法
锁获取操作
锁释放操作
锁查询操作
保存点操作
锁时长转换
死锁检测
伪随机数生成
用于随机遍历 MDL_lock 哈希表中的未使用对象进行清理。

实际应用流程
执行 SELECT * FROM users;
创建 MDL_request：SR 锁请求
acquire_lock()：获得 SR 锁
创建 MDL_ticket：插入 m_tickets[MDL_STATEMENT]
执行 SELECT：持有锁期间
release_statement_locks()：语句结束，自动释放
执行 BEGIN; ALTER TABLE users ADD COLUMN age INT; COMMIT;
BEGIN：开始事务
ALTER TABLE：
获得 SU 锁（可升级）
升级到 X 锁
插入 m_tickets[MDL_TRANSACTION]
COMMIT：调用 release_transactional_locks() 释放所有事务锁
执行 LOCK TABLES users READ;
LOCK TABLES：获得 SRO 锁
插入 m_tickets[MDL_EXPLICIT]
UNLOCK TABLES：显式释放，不受 COMMIT 影响
关键设计特点
三层锁管理：不同释放时机提供灵活的锁控制
反向时间顺序：便于快速回滚到保存点
死锁检测：通过等待图和权重机制
快速路径优化：在等待时转为普通路径
线程安全：使用读写锁保护关键数据结构
```

#2.notes

```cpp
/** Context of the owner of metadata locks. I.e. each serverconnection has such a context.*/
class MDL_context  //元数据锁的环境，即元数据锁的上下文，不是一个具体的元数据锁对象，而是元
数据锁的周围环境，所以定义了很多相关操作如加锁、释放锁等
{
public:
...
    bool try_acquire_lock(MDL_request *mdl_request);//尝试加元数据锁
    bool acquire_lock(MDL_request *mdl_request, ulong lock_wait_timeout);
    //加单个元数据锁
    bool acquire_locks(MDL_request_list *requests, ulong lock_wait_timeout);
    //一次性批量加多个元数据排它锁，用于RENAME、DROP等操作
    bool upgrade_shared_lock(MDL_ticket *mdl_ticket,//升级共享锁为排它锁，不存在并发竞
    争才可升级
                             enum_mdl_type new_type,
                             ulong lock_wait_timeout);
...
    void release_all_locks_for_name(MDL_ticket *ticket);
                                                    //从一堆元数据锁中释放指定元数据锁
    void release_lock(MDL_ticket *ticket);          //释放特定元数据锁
...
    void release_statement_locks();                 //释放语句级元数据锁
    void release_transactional_locks();             //释放事务级元数据锁
    void rollback_to_savepoint(const MDL_savepoint &mdl_savepoint);
    //回滚到指定报存点
...
public:
    /** If our request for a lock is scheduled, or aborted by the deadlock
        detector, the result is recorded in this class. */
    MDL_wait m_wait;
private:
    /**
        Lists of all MDL tickets acquired by this connection.
        //本会话已经获得的所有的元数据锁
        Lists of MDL tickets:
        ---------------------
        The entire set of locks acquired by a connection can be separated
        //按照锁被释放的情况把锁又划分为三类
        in three subsets according to their duration: locks released at the end of statement,
        at the end of transaction and locks are released explicitly.
        Statement and transactional locks are locks with automatic scope.
        //上述三种锁的前两种，是数据库引擎自动管理的，
        They are accumulated in the course of a transaction, and released
        //事务或语句结束就释放
        either at the end of uppermost statement (for statement locks) or
        on COMMIT, ROLLBACK or ROLLBACK TO SAVEPOINT (for transactional
        locks). They must not be (and never are) released manually,
        i.e. with release_lock() call.
        Tickets with explicit duration are taken for locks that span
        //上述三种锁的第三种，是用户主动管理的，
        multiple transactions or savepoints.
        //如用户可以调用RELEASE_LOCK()函数释放锁
        These are: HANDLER SQL locks (HANDLER SQL is
        transaction-agnostic), LOCK TABLES locks (you can COMMIT/etc
        under LOCK TABLES, and the locked tables stay locked), user level
        locks (GET_LOCK()/RELEASE_LOCK() functions) and
        locks implementing "global read lock".
        Statement/transactional locks are always prepended to the
        beginning of the appropriate list. In other words, they are
        stored in reverse temporal order. Thus, when we rollback to
        //注意数据结构，反向存储，所以front()方法的使用
        a savepoint, we start popping and releasing tickets from the
        front until we reach the last ticket acquired after the savepoint.
        Locks with explicit duration are not stored in any
        particular order, and among each other can be split into
        four sets://上述三种锁的第三种，又细分为四类
        - LOCK TABLES locks
        - User-level locks
        - HANDLER locks
        - GLOBAL READ LOCK locks */
    Ticket_list m_tickets[MDL_DURATION_END];
    //本会话内部所有的已经授予的MDL锁，注意是数组列表，数组根据锁的生命周期分为三类
    MDL_context_owner *m_owner;
...
    /**Tell the deadlock detector what metadata lock or tabledefinition cache
     entry this session is waiting for.
        In principle, this is redundant, as information can be foundby inspecting
        waiting queues,
        but we'd very much like it to bereadily available to the wait-for graph iterator.*/
    MDL_wait_for_subgraph *m_waiting_for;  //等待图对象，表明本会话在等什么元数据锁
...
public:
    void find_deadlock(); //从m_waiting_for出发找出死锁（m_waiting_for表明有锁等待），
    即从死锁的环中找出受害者。
    //A fragment of recursive traversal of the wait-for graph ofMDL contexts in
    the server in search for deadlocks.
    bool visit_subgraph(MDL_wait_for_graph_visitor *dvisitor);
    /** Inform the deadlock detector there is an edge in the wait-for graph. */
    void will_wait_for(MDL_wait_for_subgraph *waiting_for_arg)
    {...}
...
};
```

#3.class MDL_context

```cpp
//mdl_context在MySQL为每一个connection创建thd时，初始化一个mdl上下文，保存了当前session请求的mdl信息。
/**
  Context of the owner of metadata locks. I.e. each server
  connection has such a context.
*/

class MDL_context
{
public:
  /**
    If our request for a lock is scheduled, or aborted by the deadlock
    detector, the result is recorded in this class.
  */
  MDL_wait m_wait;
private:
  /**
    Lists of all MDL tickets acquired by this connection.

    Lists of MDL tickets:
    ---------------------
    The entire set of locks acquired by a connection can be separated
    in three subsets according to their duration: locks released at
    the end of statement, at the end of transaction and locks are
    released explicitly.

    Statement and transactional locks are locks with automatic scope.
    They are accumulated in the course of a transaction, and released
    either at the end of uppermost statement (for statement locks) or
    on COMMIT, ROLLBACK or ROLLBACK TO SAVEPOINT (for transactional
    locks). They must not be (and never are) released manually,
    i.e. with release_lock() call.

    Tickets with explicit duration are taken for locks that span
    multiple transactions or savepoints.
    These are: HANDLER SQL locks (HANDLER SQL is
    transaction-agnostic), LOCK TABLES locks (you can COMMIT/etc
    under LOCK TABLES, and the locked tables stay locked), user level
    locks (GET_LOCK()/RELEASE_LOCK() functions) and
    locks implementing "global read lock".

    Statement/transactional locks are always prepended to the
    beginning of the appropriate list. In other words, they are
    stored in reverse temporal order. Thus, when we rollback to
    a savepoint, we start popping and releasing tickets from the
    front until we reach the last ticket acquired after the savepoint.

    Locks with explicit duration are not stored in any
    particular order, and among each other can be split into
    four sets:
    - LOCK TABLES locks
    - User-level locks
    - HANDLER locks
    - GLOBAL READ LOCK locks
  */

  /**
    Read-write lock protecting m_tickets member.

    @note m_tickets is only manipulated by the owner thread itself,
          but may be read simultaneously by thread querying metadata_locks
          of information_schema.
  */
  mysql_prlock_t m_LOCK_tickets;
  bool destroyed;
  Ticket_list m_tickets[MDL_DURATION_END];
  MDL_context_owner *m_owner;
  /**
    TRUE -  if for this context we will break protocol and try to
            acquire table-level locks while having only S lock on
            some table.
            To avoid deadlocks which might occur during concurrent
            upgrade of SNRW lock on such object to X lock we have to
            abort waits for table-level locks for such connections.
    FALSE - Otherwise.
  */
  bool m_needs_thr_lock_abort;
  
  
  /**
    Indicates that we need to use DEADLOCK_WEIGHT_DML deadlock
    weight for this context and ignore the deadlock weight provided
    by the MDL_wait_for_subgraph object which we are waiting for.

    @note Can be changed only when there is a guarantee that this
          MDL_context is not waiting for a metadata lock or table
          definition entry.
  */
  bool m_force_dml_deadlock_weight;

  /**
    Read-write lock protecting m_waiting_for member.

    @note The fact that this read-write lock prefers readers is
          important as deadlock detector won't work correctly
          otherwise. @sa Comment for MDL_lock::m_rwlock.
  */
  mysql_prlock_t m_LOCK_waiting_for;
  /**
    Tell the deadlock detector what metadata lock or table
    definition cache entry this session is waiting for.
    In principle, this is redundant, as information can be found
    by inspecting waiting queues, but we'd very much like it to be
    readily available to the wait-for graph iterator.
   */
  MDL_wait_for_subgraph *m_waiting_for;
  /**
    Thread's pins (a.k.a. hazard pointers) to be used by lock-free
    implementation of MDL_map::m_locks container. NULL if pins are
    not yet allocated from container's pinbox.
  */
  LF_PINS *m_pins;
  /**
    State for pseudo random numbers generator (PRNG) which output
    is used to perform random dives into MDL_lock objects hash
    when searching for unused objects to free.
  */
  uint m_rand_state;
};  
```