#1.innobase_rollback

```cpp
innobase_rollback()
{
trx_rollback_for_mysql(trx) ->trx_rollback_low() -> trx_rollback_for_mysql_low()
 -> trx_rollback_to_savepoint_low()
    {
        ->trx_rollback_finish()
            -> trx_commit(trx)
                -> trx_commit_low()
                    ->trx_commit_in_memory()  //无论是提交还是回滚，都需要调用此函数，
标志一个事务的操作正常或非正常“结束”，数据最终是一致的，本事务的数据是可以被其他事务可见的
                        {
                        -> lock_trx_release_locks()
                           {
                               trx->state = TRX_STATE_COMMITTED_IN_MEMORY;
//内存中设置事务提交的标志，本事务的数据即刻被其他事务可见
                               ...  //省略一些代码
                               lock_release(trx);  //在设置事务提交已经完成的标志后才
释放锁。锁在设置提交标志后才释放，符合SS2PL协议
                           }
                           ...
                           lsn_t  lsn = mtr->commit_lsn();//获得最新的LSN
                           if (lsn == 0) {
                               /* Nothing to be done. */
                           } else if (trx->flush_log_later) {
                               /* Do nothing yet */
                               trx->must_flush_log_later = true;
                           } else if (srv_flush_log_at_trx_commit == 0
　　　　　　　　　　　　　//innodb_flush_log_at_trx_commit参数值为0，则不进行“预写日志”
                                      || thd_requested_durability(trx->mysql_thd)
                                          == HA_IGNORE_DURABILITY) {
                               /* Do nothing */
                           } else {  //否则，innodb_flush_log_at_trx_commit参数值为
　　　　　　　　　　　　　　　　　1，一定进行“预写日志”
                               trx_flush_log_if_needed(lsn, trx);
                     //第一次写日志的机会，此时写日志，则符合预写日志机制
                           }
                           trx->commit_lsn = lsn;
//把LSN赋值到事务结构体，待下面执行trx_commit_complete_for_mysql(trx)时再刷出日志
...
                           trx_roll_savepoints_free(trx, savep);
//释放保存点（无论是提交还是回滚都需要释放保存点）
 ...
                           if (trx->abort) {   //如果是事务回滚
...
                               trx->state = TRX_STATE_FORCED_ROLLBACK;
//如果是事务回滚，则设置事务的状态标志为回滚标志
 ...
                           } else {
                               trx->state = TRX_STATE_NOT_STARTED;  //事务正常结束
                           }
 ...
                        }
...
    }
...
    if (!read_only) {
        trx_commit_complete_for_mysql(trx);  //重要的步骤：刷出日志（刷出日志的过程可参
        见下一节“日志落盘”中的标题二）
        {   //第二次写日志的机会，此时写日志，则不符合预写日志机制（从传统数据库理论的角度看，
不区分事务的内存态方式和外存态方式，则符合WAL）。可参见10.3.3节相关讨论
            trx_flush_log_if_needed(lsn, trx) -> trx_flush_log_if_needed_low() ->
            log_write_up_to(lsn, flush);
        }
    }
}

```