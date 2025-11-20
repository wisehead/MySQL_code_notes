#1.struct rw_lock_t

InnoDB提供一种自旋锁，是基于操作系统的Test-And-Sety原子指令实现，在InnoDB内部被称为读写锁(read-write lock)。


```cpp
/** The structure used in the spin lock implementation of a read-write
lock. Several threads may have a shared lock simultaneously in this
//读锁可以有多个施加者
lock, but only one writer may have an exclusive lock, in which case no
//写锁只有一个施加者
shared locks are allowed. To prevent starving of a writer blocked by
readers, a writer may queue for x-lock by decrementing lock_word: no
//排它锁/写锁，写操作施加x锁
new readers will be let in while the thread waits for readers to
exit. */
struct rw_lock_t
#ifdef UNIV_SYNC_DEBUG
    : public latch_t
#endif /* UNIV_SYNC_DEBUG */
{
    volatile lintlock_word;//锁的值，真正的记录锁的状态标志变量，读写锁就是在此设置不同的值
    表示不同的锁
    volatile ulint   waiters;/*!< 1: there are waiters */  //谁在等待本锁
    volatile ibool   recursive;//缺省值为FALSE，不递归。
    volatile ulint   sx_recursive;/*!< number of granted SX locks. */
    volatile os_thread_id_t    writer_thread;  //写操作的线程的ID
    os_event_t   event;   /*!< Used by sync0arr.cc for thread queueing */  //OS事件
    os_event_t    wait_ex_event;  //下一个写操作等待者正在等待的OS事件
    /*!< Event for next-writer to wait on. A threadmust decrement lock_word
     before waiting. */
#ifndef INNODB_RW_LOCKS_USE_ATOMICS
    mutable ib_mutex_tmutex;    /*!< The mutex protecting rw_lock_t */
    //Mutex锁，ib_mutex_t的描述参见11.2.2节
#endif /* INNODB_RW_LOCKS_USE_ATOMICS */
    UT_LIST_NODE_T(rw_lock_t) list;  //所有的读写锁list
...
};
```