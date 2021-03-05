#1.lock_release

```cpp
caller:
trx_commit_in_memory/trx_free_prepared
--trx_release_impl_and_expl_locks
----lock_trx_release_locks

lock_release
--trx_mutex_enter(trx);
--while ((lock = UT_LIST_GET_LAST(trx->lock.trx_locks)) != nullptr)
----if (lock_get_type_low(lock) == LOCK_REC)
------lock_rec_dequeue_from_page
----else
------table->query_cache_inv_id = max_trx_id;
------lock_table_dequeue
--trx_mutex_exit
```