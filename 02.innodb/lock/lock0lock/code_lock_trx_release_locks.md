#1.lock_trx_release_locks

```cpp
/*********************************************************************//**
Releases a transaction's locks, and releases possible other transactionswaiting
because of these locks. Change the state of the transaction to TRX_STATE_
COMMITTED_IN_MEMORY. *///这段注释表明了lock_trx_release_locks()函数的功能
void
lock_trx_release_locks(
/*===================*/
    trx_t*    trx)    /*!< in/out: transaction */
{...
    /* The following assignment makes the transaction committed in memory
    //这段注释很重要，需要重点理解
    and makes its changes to data visible to other transactions.
    //在内存里提交后，本事务的数据即对其他事务可见
    NOTE that there is a small discrepancy from the strict formal
    //存在的一个问题：违反了WAL预写日志的机制
    visibility rules here: a human user of the database can see
    //注释在说：即使违反了WAL预写日志的机制，InnoDB也能保证正确性
    modifications made by another transaction T even before the necessary
    log segment has been flushed to the disk. If the database happens to
    crash before the flush, the user has seen modifications from T which
    //在日志被刷出前，恰巧数据库引擎崩溃，而事务T被标识已经提交
    will never be a committed transaction. However, any transaction T2
    //即使事务T2看到了事务T崩溃前且还没有刷出的数据，事务T2要想使
    which sees the modifications of the committing transaction T, and
    //自己的修改生效，T2需要获取一个比事务T的LSN更大的一个LSN
    which also itself makes modifications to the database, will get an lsn
    //当系统恢复的时候，事务T因为没有预写日志而被回滚，而事务T2也只能回滚（暗含之意是LSN会被用
     于识别并发事务的提交顺序）
    larger than the committing transaction T. In the case where the log
    //刷出日志时需要使用LSN判断合法性
    flush fails, and T never gets committed, also T2 will never get
    committed. */
    /*--------------------------------------*/
    trx->state = TRX_STATE_COMMITTED_IN_MEMORY;//此状态一旦设置，则本事务修改的数据则可
    以被其他事务所见（此时日志还没有被刷出到外存）
...
    lock_release(trx); //释放事务锁（事务状态已经被设置，表明提交已经完成，本事务的数据可以
    被其他事务所见到，所以可以释放锁，这就是SS2PL中提交点应该在何时设置的技术本质）
...
}
```