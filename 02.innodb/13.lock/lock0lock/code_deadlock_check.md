#1.deadlock_check

```cpp
/**
Check and resolve any deadlocks
@param[in, out] lock        The lock being acquired
@return DB_LOCK_WAIT, DB_DEADLOCK, or DB_QUE_THR_SUSPENDED, orDB_SUCCESS_LOCKED_REC;
    DB_SUCCESS_LOCKED_REC means thatthere was a deadlock, but another transaction
    was chosenas a victim,
    and we got the lock immediately: no need towait then */
dberr_t
RecLock::deadlock_check(lock_t* lock)  //检查并解决死锁问题
{...
    trx_mutex_exit(m_trx);
    const trx_t*    victim_trx;
    victim_trx = DeadlockChecker::check_and_resolve(lock, m_trx); //挑出一个受害者
    trx_mutex_enter(m_trx);
    /* Check the outcome of the deadlock test. It is possible that
    the transaction that blocked our lock was rolled back and wewere granted our lock. */
    dberr_t    err = check_deadlock_result(victim_trx, lock);
...
    return(err);
}

```