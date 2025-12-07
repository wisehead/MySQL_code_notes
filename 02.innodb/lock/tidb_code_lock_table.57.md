#1.lock_table

```cpp
lock_table
--lock_table_has//判断是否含有更高级的锁
--if ((mode == LOCK_IX || mode == LOCK_X) && !trx->read_only && trx->rsegs.m_redo.rseg == 0)
----trx_set_rw_mode(trx);
--wait_for = lock_table_other_has_incompatible
--if (wait_for != NULL)
----//....
--else
----lock_table_create
```

#2.lock_table_create

```cpp
lock_table_create
--if (trx->lock.table_cached < trx->lock.table_pool.size())
----lock = trx->lock.table_pool[trx->lock.table_cached++];
--lock->type_mode = ib_uint32_t(type_mode | LOCK_TABLE);
--lock->trx = trx;
--lock->tab_lock.table = table;
--locksys::add_to_trx_locks
----UT_LIST_ADD_LAST(lock->trx->lock.trx_locks, lock);
--ut_list_append(table->locks, lock, TableLockGetNode());
--lock->trx->lock.table_locks.push_back(lock);
```