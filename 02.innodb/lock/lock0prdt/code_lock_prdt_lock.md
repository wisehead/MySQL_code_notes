#1.lock_prdt_lock

```cpp
/*********************************************************************//**
Acquire a predicate lock on a block
@return DB_SUCCESS, DB_LOCK_WAIT, DB_DEADLOCK, or DB_QUE_THR_SUSPENDED */
//同样存在死锁的可能
dberr_t
lock_prdt_lock(
    buf_block_t*    block,     /*!< in/out: buffer block of rec */
    //被加锁的对象，是一个数据块，但加锁信息记录在块头，所以使用了控制块
    lock_prdt_t*    prdt,      /*!< in: Predicate for the lock */    //谓词锁
    dict_index_t*   index,     /*!< in: secondary index */
    lock_mode       mode,      /*!< in: mode of the lock which the read cursor
should set on records: LOCK_S or LOCK_X;
                                      the latter is possible in SELECT FOR UPDATE */
    ulint          type_mode,  /*!< in: LOCK_PREDICATE or LOCK_PRDT_PAGE */
    //LOCK_PREDICATE是谓词锁，LOCK_PRDT_PAGE是页锁
    que_thr_t*     thr,        /*!< in: query thread (can be NULL if BTR_NO_
LOCKING_FLAG) */
    mtr_t*         mtr)        /*!< in/out: mini-transaction */
{...
    if (trx->read_only || dict_table_is_temporary(index->table)) {
    //只读事务或使用临时表（临时表属于特定会话无并发）则不加锁
        return(DB_SUCCESS);
    }
...
    hash_table_t*    hash = type_mode == LOCK_PREDICATE
    //根据锁的mode，获取在全局锁表中的对应的hash锁表
        ? lock_sys->prdt_hash
        : lock_sys->prdt_page_hash;
...
    const ulint    prdt_mode = mode | type_mode;
    //形成要申请的锁的最终标识，如mode为LOCK_S, type_mode为LOCK_PREDICATE
    lock_t*        lock = lock_rec_get_first_on_page(hash, block);
    //在要加锁的对象上看，是否有旧的锁存在，便于并发冲突判断
    //锁是存在于被加锁对象上的，也会被注册到对应的hash表上，如lock_sys的prdt_hash 或prdt_page_hash
    if (lock == NULL) {  //在要加锁的对象上看到没有锁存在，意味着申请加锁成功
        RecLock    rec_lock(index, block, PRDT_HEAPNO, prdt_mode);
    //则生成一个新的记录锁在指定的索引index上
        lock = rec_lock.create(trx, false, true);
        //第三个参数值true表示要加到hash表上（prdt_hash或prdt_page_hash）
        status = LOCK_REC_SUCCESS_CREATED;
    } else {  //在要加锁的对象上看到有锁存在，可能加锁会不成功
        trx_mutex_enter(trx);
        if (lock_rec_get_next_on_page(lock)
        //根据锁能找到与之匹配的合适的记录锁在页面上
            || lock->trx != trx                           //不是同一个会话
            || lock->type_mode != (LOCK_REC | prdt_mode)  //不是记录锁与谓词锁
            || lock_rec_get_n_bits(lock) == 0             //锁标志位没有置位
            || ((type_mode & LOCK_PREDICATE) && (!lock_prdt_consistent(lock_get_
            prdt_from_lock(lock), prdt, 0))))
            //是谓词锁，但已经存在的锁和新申请的锁不相容，相容性通过
            //lock_prdt_consistent()判断
        {
            lock = lock_prdt_has_lock(mode, type_mode, block, prdt, trx);
            //在指定页面，检查是否有已经授予的更强的或相当的锁
            if (lock == NULL) {    //在指定页面，不存在“有已经授予的更强的或相当的锁”
                const lock_t*    wait_for;
                wait_for = lock_prdt_other_has_conflicting(prdt_mode, block, prdt, trx);
              //检查是否有其他会话持有这样的锁
              if (wait_for != NULL) {
              //检查是否有其他会话持有这样的锁，如有则本会话需要等待
                    RecLock  rec_lock(thr, index, block, PRDT_HEAPNO, prdt_mode, prdt);
                    err = rec_lock.add_to_waitq(wait_for);
                    //需要等待则加入等待队列，会进行死锁判断（参见11.3.2节第5小节）
                } else {         //检查是否有其他会话持有这样的锁，如没有则本会话可以加锁
                    lock_prdt_add_to_queue(prdt_mode, block, index, trx, prdt, true);
                    //把锁加入谓词锁队列，注册到hash表中
                    status = LOCK_REC_SUCCESS;
                }
            }
            trx_mutex_exit(trx);
        } else {  //同一个会话内（即同一个事务）、不能根据锁能找到与之匹配的合适的记录锁在页
面上等if没有限定的情况都走到这里
            trx_mutex_exit(trx);
            if (!lock_rec_get_nth_bit(lock, PRDT_HEAPNO)) {
                lock_rec_set_nth_bit(lock, PRDT_HEAPNO);
                status = LOCK_REC_SUCCESS_CREATED;
            }
        }
    }
    lock_mutex_exit();
    if (status == LOCK_REC_SUCCESS_CREATED && type_mode == LOCK_PREDICATE) {
    //加谓词锁成功
        /* Append the predicate in the lock record */
        lock_prdt_set_prdt(lock, prdt);
        //加谓词锁成功，则把谓词锁保存（通过内存拷贝）在lock对象上
    }
    return(err);
}
```