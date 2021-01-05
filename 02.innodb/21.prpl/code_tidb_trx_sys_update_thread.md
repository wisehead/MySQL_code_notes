#1.ncdb_trx_sys_update_thread

```cpp
caller:
--log_scan_handler

ncdb_trx_sys_update_thread
--while (srv_shutdown_state == SRV_SHUTDOWN_NONE && rpl_sys->m_slave_running)
----/** Flush the trx ids modifications to the trx_sys's rw_trx_ids
		in the slave, and make a fresh readview in the readview cache.
	 */
----trx_slave_flush_ids
------mutex_enter(&trx_sys->flush_mutex);
------mutex_enter(&trx_sys->ids_mutex);
------end_size = trx_sys->trx_end_ids.size();
----os_thread_sleep(srv_ncdb_trx_sys_update_frequency * 1000);
--//end while
--trx_sys->mvcc->cleanup_read_view();
```