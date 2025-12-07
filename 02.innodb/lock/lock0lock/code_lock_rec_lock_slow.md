#1.lock_rec_lock_slow

```cpp
/*********************************************************************//**
This is the general, and slower, routine for locking a record. This is alow-level
function which does NOT look at implicit locks!
Checks lockcompatibility within explicit locks.
This function sets a normal next-keylock, or in the case of a page supremum
record, a gap type lock.
@return DB_SUCCESS, DB_SUCCESS_LOCKED_REC, DB_LOCK_WAIT, DB_DEADLOCK,
or DB_QUE_THR_SUSPENDED */
static
dberr_t
lock_rec_lock_slow(...)  //参数省略，同上层的lock_rec_lock()函数
{...
    trx_mutex_enter(trx);
    if (lock_rec_has_expl(mode, block, heap_no, trx)) {
    //是否在同一个事务内存在更强的锁
        /* The trx already has a strong enough lock on rec: donothing */
        err = DB_SUCCESS;  //在同一个事务内存在更强的锁，则不需要申请新锁，这是锁的升级相容
        问题，参见表11-7
    } else {
        const lock_t* wait_for = lock_rec_other_has_conflicting(mode, block, heap_no, trx);
        //本事务trx是否被其他有显式锁的事务阻塞
        if (wait_for != NULL) {   //存在有冲突的锁，只能等待（新建锁，但新建的锁需要进入
                                     等待队列）
            /* If another transaction has a non-gap conflictingrequest in the
            queue, as this transaction does not
have a lock strong enough already granted on therecord, we may have to wait. */
            RecLock  rec_lock(thr, index, block, heap_no, mode);
            err = rec_lock.add_to_waitq(wait_for); //新锁进入等待队列。并进行死锁判
            断，死锁判断将是一个耗时的过程，“slow”在此体现
        } else if (!impl) {
            /* Set the requested lock on the record, note thatwe already own the
              transaction mutex. */
            lock_rec_add_to_queue(LOCK_REC | mode, block, heap_no, index,
            trx,true); //不是隐含锁，则把加锁请求加入等待队列
            err = DB_SUCCESS_LOCKED_REC;
        } else {
            err = DB_SUCCESS;
        }
    }
    trx_mutex_exit(trx);
    return(err);
}


```