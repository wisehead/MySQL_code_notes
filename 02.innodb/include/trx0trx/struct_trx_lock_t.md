#1.struct trx_lock_t

```cpp
/** The locks and state of an active transaction. Protected by lock_sys->mutex,
 trx->mutex or both. */
struct trx_lock_t {  //某一个活跃事务的锁及其状态
    ulint          n_active_thrs;    /*!< number of active query threads */
    trx_que_t      que_state;        /*!< valid when trx->state
                      包含有四种可顾名思义的状态: TRX_QUE_RUNNING, TRX_QUE_LOCK_WAIT,
 TRX_QUE_ROLLING_BACK，TRX_QUE_COMMITTING */
    lock_t*        wait_lock;        //指向请求的锁
    ib_uint64_t    deadlock_mark;    //死锁标志
    bool           was_chosen_as_deadlock_victim; //是否被选为了受害者
    time_t         wait_started;     //处于锁等待的起始时间，便于用锁超时进行时间检测判断
    que_thr_t*     wait_thr;         //正在等哪个会话
    lock_pool_t    rec_pool;     /*!< Pre-allocated record locks */
    //一个事务上预先分配的记录锁缓存池。lock_pool_t的定义
    lock_pool_t    table_pool;   /*!< Pre-allocated table locks */
    //一个事务上预先分配的表锁缓存池
    ulint          rec_cached;    /*!< Next free rec lock in pool */
    ulint          table_cached;  /*!< Next free table lock in pool */
    mem_heap_t*    lock_heap;    //锁的内存空间，是从这个堆上申请的
    trx_lock_list_t  trx_locks;   //locks requested by the transaction;
   //事务已经申请到的事务的锁的双向列表
    lock_pool_t    table_locks;  //本事务内的所有的表锁
    bool           cancel;      //本事务是否被取消（被回滚或超时等待发生将认为事务被取消）
    ulint          n_rec_locks;  //本事务内的所有记录锁
    /** The transaction called ha_innobase::start_stmt() to lock a table. Most
    likely a temporary table. */
    bool           start_stmt;
};
```