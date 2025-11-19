#1.struct trx_sys_t

```cpp
/** The transaction system central memory data structure. */
struct trx_sys_t {...
    MVCC*        mvcc;        /*!< Multi version concurrency controlmanager */
    //MVCC机制的管理器，相关详情参见第12章
    volatile trx_id_t max_trx_id;  /*!< The smallest number not yet assigned as
     a transaction id ortransaction number. This is declared
                    volatile because it can be accessed without holding any mutex
                     duringAC-NL-RO view creation. */
                    //对于每个事务都有一个ID，已存在的所有事务的最大ID小于max_trx_id，这
                      表明max_trx_id是即将待分配的事务ID的最小值
    trx_ut_list_t    serialisation_list;  //所有当前处于ACTIVE状态的读写事务按trx_
    t::no有序的一个列表
...
    trx_ut_list_t    rw_trx_list;  //所有处于AVTIVE和COMMITTED状态的在内存的读写事务列
    表，按事务id倒排有序。Recovered事务和数据库引擎自身发起的事务在此列表
...
    trx_ut_list_t    mysql_trx_list; //所有的用户发起的事务列表。还包括正在发起的事务但还
没有发起完成
    trx_ids_t        rw_trx_ids;    /*!< Read write transaction IDs */
...
    trx_rseg_t*    rseg_array[TRX_SYS_N_RSEGS]; //系统的回滚段，最大TRX_SYS_N_RSEGS为128个
    ulint          rseg_history_len;
    trx_rseg_t*    const pending_purge_rseg_array[TRX_SYS_N_RSEGS];
    //用于PURGE操作的回滚段
    TrxIdSet       rw_trx_set;    /*!< Mapping from transaction idto transaction instance */
    ulint          n_prepared_trx;    /*!< Number of transactions currentlyin the
     XA PREPARED state */
    ulint          n_prepared_recovered_trx; /*!< Number of transactions
     currently in XA PREPARED state that arealso recovered.
                       Such transactions cannotbe added during runtime. They can
    only occur after recoveryif mysqld crashed
                       while there were XA PREPAREDtransactions. We disable query
                       cache if such transactions exist. */
};
```