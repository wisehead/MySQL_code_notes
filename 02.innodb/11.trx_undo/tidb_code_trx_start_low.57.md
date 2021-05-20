#1. trx_start_low


```cpp
trx_start_low
--++trx->version;
--trx->auto_commit = (trx->api_trx && trx->api_auto_commit)|| thd_trx_is_auto_commit(trx->mysql_thd);
--trx->read_only =(trx->api_trx && !trx->read_write)|| (!trx->ddl && !trx->internal&& thd_trx_is_read_only(trx->mysql_thd))|| srv_read_only_mode|| ncdb_slave_mode();
--trx->no = TRX_ID_MAX;
--trx->min_no = TRX_ID_MAX;
--if (!trx->read_only && (trx->mysql_thd == 0 || read_write || trx->ddl)) //read write
----trx->rsegs.m_redo.rseg = trx_assign_rseg_low
----trx->id = trx_sys_get_new_trx_id();
----if (trx->id > trx_sys->rw_max_trx_id)
------trx_sys->rw_max_trx_id = trx->id;
----if (!ncdb_slave_mode())
------trx_sys->rw_trx_ids.push_back(trx->id);
----UT_LIST_ADD_FIRST(trx_sys->rw_trx_list, trx);
----trx->state = TRX_STATE_ACTIVE;
----trx_sys_rw_trx_add(trx, true);
--else//read_only
----trx->id = 0;
----if (!trx_is_autocommit_non_locking(trx))
------/* If this is a read-only transaction that is writing to a temporary table then it needs a transaction id to write to the temporary table. */
------if (read_write)
--------trx->id = trx_sys_get_new_trx_id();
--------if (!ncdb_slave_mode())
----------trx_sys->rw_trx_ids.push_back(trx->id);
--------trx_sys_rw_trx_add(trx, false);
------trx->state = TRX_STATE_ACTIVE;
----else
------trx->state = TRX_STATE_ACTIVE
--trx->start_time = thd_start_time_in_secs(trx->mysql_thd);
--trx->lock.schedule_weight.store(0, std::memory_order_relaxed);
```