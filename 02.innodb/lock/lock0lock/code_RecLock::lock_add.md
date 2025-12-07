#1.RecLock::lock_add

```cpp
//Add the lock to the record lock hash and the transaction's lock list
void
RecLock::lock_add(lock_t* lock, bool add_to_hash)
{...
    if (add_to_hash) {
        ulint    key = m_rec_id.fold();
        ++lock->index->table->n_rec_locks;
        HASH_INSERT(lock_t, hash, lock_hash_get(m_mode), key, lock);
        //把lock锁存入lock_hash_get(m_mode)指定的Hash锁表内
        //Hash锁表内共有三种，分别是记录锁Hash表、谓词锁Hash表、页锁Hash表，在lock_sys_t中定义，
          参见11.1.2节
    }
...
UT_LIST_ADD_LAST(lock->trx->lock.trx_locks, lock); //把锁lock注册到事务的锁列表内，对
应lock_rec_dequeue_from_page()中的UT_LIST_REMOVE
}
```