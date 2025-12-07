#1.enum trx_state_t

```cpp
/** Transaction states (trx_t::state) */
enum trx_state_t {
    TRX_STATE_NOT_STARTED,//没有事务，即事务没有开始
    /** Same as not started but with additional semantics that itwas rolled back
     asynchronously the last time it was active. */
    TRX_STATE_FORCED_ROLLBACK,//事务被回滚，这是从ACTIVE状态变迁过来的。并发机制经常会通
    过主动回滚事务来防止数据不一致
    TRX_STATE_ACTIVE, //事处于ACTIVE状态，表明事务正在执行的过程中
    /** Support for 2PC/XA */
    TRX_STATE_PREPARED,//事务提交阶段，为支持XA，引入了2PC技术，这是2PC的第一阶段即
     PREPARE阶段
    TRX_STATE_COMMITTED_IN_MEMORY  //事务已经提交，这是事务的提交标识。只有事务被设置为提
交标识后，才可以释放锁等资源，这是SS2PL定义的，InnoDB遵守这一点。InnoDB支持事务内存态方式提
交，可以提高事务执行效率
};
```