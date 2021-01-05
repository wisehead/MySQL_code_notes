#1.tidb_trx_sys_update_thread

```cpp
caller:
--log_scan_handler

tidb_trx_sys_update_thread
--while (srv_shutdown_state == SRV_SHUTDOWN_NONE && rpl_sys->m_slave_running)
----/** Flush the trx ids modifications to the trx_sys's rw_trx_ids
		in the slave, and make a fresh readview in the readview cache.
	 */
----trx_slave_flush_ids
------mutex_enter(&trx_sys->flush_mutex);
------mutex_enter(&trx_sys->ids_mutex);
------end_size = trx_sys->trx_end_ids.size();
------if (end_size > 0)
--------local_end.assign(trx_sys->trx_end_ids.begin(),trx_sys->trx_end_ids.end());
------if (trx_sys->slave_clean_id > 0)
--------clean_id = trx_sys->slave_clean_id;
--------trx_sys->slave_clean_id = 0;
------if (trx_sys->slave_max_trx_id > 0)
--------max_id = trx_sys->slave_max_trx_id;
--------trx_sys->slave_max_trx_id = 0;
------low_limit_no = trx_sys->slave_dyn_low_limit_no;
------mutex_exit(&trx_sys->ids_mutex);
------trx_slave_flush_ids_add(new_max_trx_id);
------trx_slave_flush_ids_remove(local_end);
------local_end.clear();
------trx_read_view_mutex_enter
------trx_sys->max_trx_id = new_max_trx_id;
------trx_sys->rw_trx_ids.assign(trx_sys->slave_trx_ids_set.begin(),trx_sys->slave_trx_ids_set.end())
------if (end_size > 0 || clean_id > 0 || low_limit_no > trx_sys->slave_low_limit_no)
--------if (clean_id > 0)
----------trx_slave_clean_id(clean_id);
--------trx_sys->mvcc->update_latest_read_view();
------trx_sys->mvcc->close_unref_read_view();
------trx_read_view_mutex_exit
------mutex_exit(&trx_sys->flush_mutex)
----os_thread_sleep(srv_tidb_trx_sys_update_frequency * 1000);
--//end while
--trx_sys->mvcc->cleanup_read_view();
```