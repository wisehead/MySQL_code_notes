#1.struct lock_sys_t

```cpp
/** The lock system struct */
struct lock_sys_t{    //全局的行级锁表结构，所有的行级锁都在这个结构体定义的lock_sys中注册
    char         pad1[CACHE_LINE_SIZE];
    LockMutex    mutex;
    hash_table_t*    rec_hash;     //全局的记录锁Hash表，所有的记录锁注册到这个Hash表里
    hash_table_t*    prdt_hash;    //全局的谓词锁Hash表，所有的谓词锁注册到这个Hash表里
    hash_table_t*    prdt_page_hash;  //全局的谓词页锁Hash表，所有的谓词页锁注册到这个Hash表里
    char             pad2[CACHE_LINE_SIZE];    /*!< Padding */
    LockMutex        wait_mutex;      //保护下面几个成员的系统锁
    srv_slot_t*      waiting_threads; //正在等待的线程会话有哪些
    srv_slot_t*      last_slot;       //在waiting_threads中的最高（最后）的一个槽
    ibool            rollback_complete;
    //所有的回滚的事务完成（伴随着事务上的锁要被释放，如调用lock_rec_discard()）
    ulint            n_lock_max_wait_time;   /*!< Max wait time */
    os_event_t       timeout_event;          //< Set to the event that is created
   in the lock wait monitor thread.
    bool             timeout_thread_active;  /*!< True if the timeout thread is running */
};
```