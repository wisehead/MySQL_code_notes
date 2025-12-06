#1.AI notes
```cpp
这段代码定义了 MDL_map 类，是 MySQL 元数据锁系统中全局单例，管理所有服务器级别的 MDL 锁对象。以下是详细解释：

核心概念
MDL_map 是一个全局哈希表，存储所有 MDL_lock 对象。它使用无锁哈希表（Lock-Free Hash）以实现高并发性能。

主要成员变量
成员	类型	用途
m_locks	LF_HASH	无锁哈希表，存储所有 MDL_lock 对象
m_global_lock	MDL_lock*	预分配的全局锁（GLOBAL 命名空间）
m_commit_lock	MDL_lock*	预分配的提交锁（COMMIT 命名空间）
m_unused_lock_objects	volatile int32	未使用的 MDL_lock 对象计数
关键方法
1. 查找操作
特点：

对于 GLOBAL 和 COMMIT 命名空间，直接返回预分配的对象（避免哈希查找开销）
其他命名空间通过 lf_hash_search() 查询
返回 pinned 标志表示对象是否被 "钉住"（hazard pointer 机制）
2. 查找或插入
如果锁不存在，则创建新的 MDL_lock 对象。采用重试循环处理并发插入的情况。

3. 未使用对象管理
递减计数
递增计数与清理
清理策略：

阈值：mdl_locks_unused_locks_low_water（默认 1000）
比例：未使用对象占总对象的 25% 以上时触发清理
方法：随机选择未使用的对象删除
4. 获取 Pins（危险指针）
每个线程在操作无锁哈希表前需要获取 pins，用于内存安全性保障。

5. 单例检查
GLOBAL 和 COMMIT 锁只有一个实例，因此被视为单例。

内存管理与优化
为什么需要预分配 GLOBAL 和 COMMIT 锁？
随机清理算法
特点：

随机选择避免偏好某些对象
使用过频繁的对象自然保留在缓存中
极少使用的对象被驱逐
无限循环风险消除（PRNG 最终覆盖所有哈希桶）
无锁设计细节
内存顺序保证
为什么计数可能为负？
初始化与销毁
实际应用流程
获取表锁
内存清理触发
性能考虑
优化	效果
GLOBAL/COMMIT 预分配	避免哈希查询（所有语句执行）
无锁哈希表	减少锁竞争，提高并发
随机清理	渐进式内存回收，避免内存泄漏
Hazard Pointers	安全的内存回收（无 GC）
原子操作	无阻塞的计数更新
这个设计在高并发场景下实现了极高的效率，同时保证内存不会无限增长。
```

#2.notes
```cpp
/**A collection of all MDL locks. A singleton,there is only one instance of the
map in the server.*/
class MDL_map    //锁集合，MDL_key到MDL_lock的一个映射。所有的元数据锁都在此中注册
{...
    inline MDL_lock *find(LF_PINS *pins, const MDL_key *key, bool *pinned);
    //查找指定key值的锁是否在map中存在
    inline MDL_lock *find_or_insert(LF_PINS *pins, const MDL_key *key, bool
     *pinned); //查找指定key值的锁，不存在则创建
...
};
```

#3.class MDL_map

```cpp
//mdl_map使用hash表，保存了MySQL所有的mdl_lock，全局共享，使用MDL_KEY作为key来表，key=【db_name+table_name】唯一定位一个表。

/**
  A collection of all MDL locks. A singleton,
  there is only one instance of the map in the server.
*/

class MDL_map
{
private:
  /** LF_HASH with all locks in the server. */
  LF_HASH m_locks;
  /** Pre-allocated MDL_lock object for GLOBAL namespace. */
  MDL_lock *m_global_lock;
  /** Pre-allocated MDL_lock object for COMMIT namespace. */
  MDL_lock *m_commit_lock;
  /**
    Number of unused MDL_lock objects in the server.

    Updated using atomic operations, read using both atomic and ordinary
    reads. We assume that ordinary reads of 32-bit words can't result in
    partial results, but may produce stale results thanks to memory
    reordering, LF_HASH seems to be using similar assumption.

    Note that due to fact that updates to this counter are not atomic with
    marking MDL_lock objects as used/unused it might easily get negative
    for some short period of time. Code which uses its value needs to take
    this into account.
  */
  volatile int32 m_unused_lock_objects;

  /** Pre-allocated MDL_lock object for BACKUP namespace. */
  MDL_lock *m_backup_lock;
  /** Pre-allocated MDL_lock object for BINLOG namespace */
  MDL_lock *m_binlog_lock;
};

```