#1.lock_rec_dequeue_from_page

```cpp

lock_rec_dequeue_from_page(  //1 去掉记录锁。  2 为等待锁的事务施加锁
    lock_t*        in_lock)    /*!< in: record lock object: allrecord locks which
    are contained inthis lock object are removed;
                    transactions waiting behind willget their lock requests
 granted, if they are now qualified to it */
{...
    in_lock->index->table->n_rec_locks--;
    lock_hash = lock_hash_get(in_lock->type_mode);  //获得记录锁对应的Hash表
    HASH_DELETE(lock_t, hash, lock_hash,            //从Hash表中去掉记录锁
                lock_rec_fold(space, page_no), in_lock);
    UT_LIST_REMOVE(trx_lock->trx_locks, in_lock);
    //同时从事务锁表中去掉记录锁。对应RecLock::lock_add()中的UT_LIST_ADD_LAST
...
}
```