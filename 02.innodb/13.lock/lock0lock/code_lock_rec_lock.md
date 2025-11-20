#1.lock_rec_lock


```cpp
/*********************************************************************//**
Tries to lock the specified record in the mode requested. If not immediatelypossible,
enqueues a waiting lock request.
This is a low-level functionwhich does NOT look at implicit locks! Checks lock
compatibility withinexplicit locks.
This function sets a normal next-key lock, or in the caseof a page supremum
record, a gap type lock.
@return DB_SUCCESS, DB_SUCCESS_LOCKED_REC, DB_LOCK_WAIT, DB_DEADLOCK,or DB_QUE_
THR_SUSPENDED */
static
dberr_t
lock_rec_lock(    //施加记录锁
    bool          impl, /*!< in: if true, no lock is setif no wait is necessary:
    weassume that the caller willset an implicit lock */
    ulint         mode,    /*!< in: lock mode: LOCK_X orLOCK_S possibly ORed to
    eitherLOCK_GAP or LOCK_REC_NOT_GAP */
    const buf_block_t*    block, /*!< in: buffer block containingthe record */
    ulint         heap_no, /*!< in: heap number of record */
    dict_index_t* index,   /*!< in: index of record */
    que_thr_t*    thr)     /*!< in: query thread */
{...
    /* We try a simplified and faster subroutine for the mostcommon cases */
    switch (lock_rec_lock_fast(impl, mode, block, heap_no, index, thr)) {
    //尝试快速加锁，如果失败，才调用更严格的lock_rec_lock_slow()
    case LOCK_REC_SUCCESS:
        return(DB_SUCCESS);  //快速加锁成功，锁存在
    case LOCK_REC_SUCCESS_CREATED:
        return(DB_SUCCESS_LOCKED_REC);//快速加锁成功，锁是新创建的
    case LOCK_REC_FAIL:
        return(lock_rec_lock_slow(impl, mode, block, heap_no, index, thr));
    //需要做更多判断才能确定的加锁机制，因多做工作所以“slow”慢
    }
...
}
```