#1.enum trx_que_t

```cpp
/** Transaction execution states when trx->state == TRX_STATE_ACTIVE */
enum trx_que_t {
    TRX_QUE_RUNNING,        /*!< transaction is running */
    //事务正在执行
    TRX_QUE_LOCK_WAIT,        /*!< transaction is waiting fora lock */
    //事务正在等待一个锁
    TRX_QUE_ROLLING_BACK,     /*!< transaction is rolling back */
    //事务正在回滚过程中
    TRX_QUE_COMMITTING        /*!< transaction is committing */
    //事务正在提交过程中
};
```