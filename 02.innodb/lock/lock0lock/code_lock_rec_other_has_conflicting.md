#1.lock_rec_other_has_conflicting

```cpp
/**Checks if some other transaction has a conflicting explicit lock requestin the
queue, so that we have to wait.
@return lock or NULL */
static
const lock_t*
lock_rec_other_has_conflicting(
    ulint            mode,    /*!< in: LOCK_S or LOCK_X,possibly ORed to LOCK_GAP
     orLOC_REC_NOT_GAP,LOCK_INSERT_INTENTION */
    const buf_block_t*   block,    /*!< in: buffer block containingthe record */
    ulint            heap_no,/*!< in: heap number of the record */
    const trx_t*        trx)   /*!< in: our transaction */
{
    const lock_t*        lock;
    ut_ad(lock_mutex_own());
    bool    is_supremum = (heap_no == PAGE_HEAP_NO_SUPREMUM);
    //遍历全局锁表lock_sys中的记录锁表rec_hash，查阅准备施加的锁（参数mode、block等表明新
      锁的情况）是否被允许
    for (lock = lock_rec_get_first(lock_sys->rec_hash, block, heap_no);
        lock != NULL;
        lock = lock_rec_get_next_const(heap_no, lock)) {  //lock是已经持有的锁
        if (lock_rec_has_to_wait(trx, mode, lock, is_supremum)) {
        //同一个事务则不存在冲突，返回值为NULL；否则，返回持锁者
            return(lock);
        }
    }
    return(NULL);
}
```