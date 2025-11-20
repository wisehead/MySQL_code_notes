#1.RecLock::add_to_waitq

```cpp

/**
Enqueue a lock wait for normal transaction. If it is a high priority
transactionthen jump the record lock wait queue
and if the transaction at the head of thequeue is itself waiting roll it back,
also do a deadlock check and resolve.
@param[in, out] wait_for    The lock that the joining transaction iswaiting for
//本锁被其他事务阻塞，所以本锁正等待其他事务完成
@param[in] prdt            Predicate [optional]  //如果参数空缺，则参数值为NULL
@return DB_LOCK_WAIT, DB_DEADLOCK, or DB_QUE_THR_SUSPENDED, orDB_SUCCESS_LOCKED_REC;
    DB_SUCCESS_LOCKED_REC means thatthere was a deadlock, but another transaction was chosen
    as a victim, and we got the lock immediately: no need towait then */
dberr_t
RecLock::add_to_waitq(const lock_t* wait_for, const lock_prdt_t* prdt)
//使得本事务处于等待状态的锁是wait_for
{...
    m_mode |= LOCK_WAIT;  //因为本事务正等待其他事务，所以加标志LOCK_WAIT
    /* Do the preliminary checks, and set query thread state */
    prepare();
...
    if (wait_for->trx->mysql_thd == NULL) {
    //mysql_thd值为NULL表明是InnoDB引擎内部发起的事务，持有锁的内部事务不能作为受害者
        victim_trx = NULL;
    } else {
        /* Currently, if both are high priority transactions thenthe requesting
     transaction will be rolled back. */
        victim_trx = trx_arbitrate(m_trx, wait_for->trx);//事务优先级相同时，发起加锁
       请求的事务为受害者；否则，事务优先级低者为受害者
    }
    if (victim_trx == m_trx || victim_trx == NULL) {
     //受害者是本事务，或者没有受害者（InnoDB引擎内部发起的事务）
        /* Ensure that the wait flag is not set. */
        lock = create(m_trx, true, prdt); //明知本事务可能被回滚，也需要创建出这个事务对应的锁
        /* If a high priority transaction has been selected asa victim there
           is nothing we can do. */
        //本事务是高优先级事务，且不是InnoDB引擎内部发起的事务，被选为受害者，本事务只能回滚
        if (trx_is_high_priority(m_trx) && victim_trx != NULL) {
        //本事务因被回滚需要去掉其锁（注意条件“victim_trx == m_trx”）
            lock_reset_lock_and_trx_wait(lock);//因要把本事务回滚，所以先把本事务锁上的
            等待相关的标志去掉
            lock_rec_reset_nth_bit(lock, m_rec_id.m_heap_no);  //同上
...
            return(DB_DEADLOCK);  //有死锁发生啦! （已经能明确知道有死锁发生，不用进一步
                                     进行死锁检测）
        }
    } else if ((lock = enqueue_priority(wait_for, prdt)) == NULL) {
     //当前事务不是受害者，lock为NULL意味着不用新加锁，锁已经被授予了
        /* Lock was granted */
        return(DB_SUCCESS);  //加锁成功
    }
    ut_ad(lock_get_wait(lock));//至此，已经明确知道必有锁等待，只好使用等待图进行死锁检测了
    dberr_terr = deadlock_check(lock);  //进行死锁检测，参见11.3.2.6节
    ut_ad(trx_mutex_own(m_trx));
    return(err);
}

```