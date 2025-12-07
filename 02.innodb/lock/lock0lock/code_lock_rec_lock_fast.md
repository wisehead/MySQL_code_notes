#1.lock_rec_lock_fast

```cpp

/*********************************************************************//**
This is a fast routine for locking a record in the most common cases:
there are no explicit locks on the page, or there is just one lock, ownedby this
transaction, and of the right type_mode.
This is a low-level functionwhich does NOT look at implicit locks! Checks lock
compatibility withinexplicit locks.
This function sets a normal next-key lock, or in the case ofa page supremum
record, a gap type lock.
@return whether the locking succeeded */
UNIV_INLINE
lock_rec_req_status
lock_rec_lock_fast(...) //参数省略，同上层的lock_rec_lock()函数
{...
    lock_t*    lock = lock_rec_get_first_on_page(lock_sys->rec_hash, block);
    //从全局记录锁表中获得数据块对应的锁的信息
    trx_t*    trx = thr_get_trx(thr);
    lock_rec_req_status    status = LOCK_REC_SUCCESS;
    if (lock == NULL) {  //全局记录锁表中不存在数据块对应的锁的信息，则新建一个记录锁
        if (!impl) {
            RecLock rec_lock(index, block, heap_no, mode);
            //记录锁，定义在指定的索引index上
            /* Note that we don't own the trx mutex. */
            rec_lock.create(trx, false);//新建一个记录锁
        }
        status = LOCK_REC_SUCCESS_CREATED;
    } else {  //全局记录锁表中存在数据块对应的锁的信息
        trx_mutex_enter(trx);
        if (lock_rec_get_next_on_page(lock)
        //存在其他的记录锁(注意本函数是get_next，不是get_first)，则锁不唯一，可能存在竞争
             || lock->trx != trx  //不是同一个事务
             || lock->type_mode != (mode | LOCK_REC)  //不是记录锁
             || lock_rec_get_n_bits(lock) <= heap_no) {
            status = LOCK_REC_FAIL;
            //这种情况下，需要进入到lock_rec_lock_slow()的慢函数中进行更为详细地判断
        } else if (!impl) {  //锁存在且不是隐含的锁，是显式加锁,则设置对应的标志位为加锁状态
            /* If the nth bit of the record lock is already setthen we do not set
                a new lock bit, otherwise we doset */
            if (!lock_rec_get_nth_bit(lock, heap_no)) {
                lock_rec_set_nth_bit(lock, heap_no); //设置对应的标志位为加锁状态
                status = LOCK_REC_SUCCESS_CREATED;
            }
        }
        trx_mutex_exit(trx);
    }
    return(status);
}

```