#1.trx_start_low

```cpp
trx_start_low(  //开始一个事务
    trx_t*    trx,        /*!< in: transaction */
    bool    read_write)    /*!< in: true if read-write transaction */
{...
    ++trx->version;
    /* Check whether it is an AUTOCOMMIT SELECT */
    trx->auto_commit = (trx->api_trx && trx->api_auto_commit)|| thd_trx_is_auto_
    commit(trx->mysql_thd);
    trx->read_only =  //根据环境、上下文等信息设置事务的一些属性值
        (trx->api_trx && !trx->read_write)
        || (!trx->ddl && !trx->internal && thd_trx_is_read_only(trx->mysql_thd))
        || srv_read_only_mode;
...
    /* The initial value for trx->no: TRX_ID_MAX is used inread_view_open_now: */
    trx->no = TRX_ID_MAX;
...
    /* By default all transactions are in the read-only list unless they
    are non-locking auto-commit read only transactions or background
    (internal) transactions. Note: Transactions marked explicitly as
    read only can write to temporary tables, we put those on the RO
    list too. */
    if (!trx->read_only && (trx->mysql_thd == 0 || read_write || trx->ddl))
    //非只读事务
    {
        trx->rsegs.m_redo.rseg = trx_assign_rseg_low(  //对于非只读事务，分配回滚段
            srv_undo_logs, srv_undo_tablespaces,
            TRX_RSEG_TYPE_REDO);
        /* Temporary rseg is assigned only if the transactionupdates a temporary table */
        //对于非只读类型的事务，事务刚开始不能确定是否要用到临时表，所以临时表要使用到的临时回
         滚段暂且不分配
        trx_sys_mutex_enter();
        trx->id = trx_sys_get_new_trx_id();//获取一个事务ID
        trx_sys->rw_trx_ids.push_back(trx->id);
...
        trx->state = TRX_STATE_ACTIVE;  //设置事务状态为ACTIVE，由此表明在一个SESSION
        内部，事务开始了
...
    } else {
        trx->id = 0;
        if (!trx_is_autocommit_non_locking(trx)) {   //只读事务，需要写临时表，而临时
             表需要通过事务的ID做区分
            /* If this is a read-only transaction that is writing
            to a temporary table then it needs a transaction id
            to write to the temporary table. */
            if (read_write) {
...
                trx->id = trx_sys_get_new_trx_id();//获取一个事务ID
                trx_sys->rw_trx_ids.push_back(trx->id);
                trx_sys->rw_trx_set.insert(TrxTrack(trx->id, trx));
...
            }
            trx->state = TRX_STATE_ACTIVE;  //设置事务状态为ACTIVE
        } else {  //对于只读事务,没有事务ID，只标识事务的状态为开始
            ut_ad(!read_write);
            trx->state = TRX_STATE_ACTIVE;  //设置事务状态为ACTIVE，每个条件判断都有同
                                              样的语句，其实可以放到条件外面只写一次
        }
    }
    if (trx->mysql_thd != NULL) {  //设置事务的启动时间
        trx->start_time = thd_start_time_in_secs(trx->mysql_thd);
    } else {
        trx->start_time = ut_time();
    }
...
}



```