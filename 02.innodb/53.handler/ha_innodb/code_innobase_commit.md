#1.innobase_commit

```cpp

/*****************************************************************//**
Commits a transaction in an InnoDB database or marks an SQL statement ended.
@return 0 or deadlock error if the transaction was aborted by anotherhigher
priority transaction. */
static
int
innobase_commit(  //提交一个事务，完成事务提交的标识，然后刷出日志（如此的方式，违反了WAL预
                    写日志的机制）
    handlerton*    hton,    /*!< in: InnoDB handlerton */ //InnoDB引擎的句柄
    THD*           thd,    /*!< in: MySQL thread handle of theuser for whom the
transaction shouldbe committed */ //用户会话
    bool           commit_trx)    /*!< in: true - commit transactionfalse - the
current SQL statementended */  //是否提交
{...
    if (commit_trx  //值为TRUE表示要提交事务
        || (!thd_test_options(thd, OPTION_NOT_AUTOCOMMIT | OPTION_BEGIN))) {
...
    innobase_commit_low(trx); //调用栈： -> trx_commit_for_mysql() -> trx_
   commit(trx) ->trx_commit_low() -> trx_commit_in_memory() -> lock_trx_release_
   locks()，在lock_trx_release_locks()这个函数中执行如下重要代码：
    //trx->state = TRX_STATE_COMMITTED_IN_MEMORY;  即在内存中设置事务提交已经完成的标
    志，本事务的数据即刻被其他事务可见
    //...  省略一些代码
    //lock_release(trx);  在设置事务提交已经完成的标志后才释放锁。锁在设置提交标志后才释
    放，符合SS2PL协议
...
        /* Now do a write + flush of logs. */
        if (!read_only) {
            trx_commit_complete_for_mysql(trx);
            //重要的步骤：刷出日志（刷出日志的过程可参见10.3.4节的内容）
        }
    } else {//不提交事务
...
    }
...
}
```