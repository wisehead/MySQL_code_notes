#1.ncdb_log_finish_thread

```cpp
DECLARE_THREAD(ncdb_log_finish_thread)
--conn = (ncdb_conn*)ar
--rbuf = conn->get_rbuf()
--while (srv_shutdown_state != SRV_SHUTDOWN_EXIT_THREADS|| !rbuf->is_empty())
----ncdb_conn::write_log_finish
------ncdb_conn::get_VDL
----LogRingBuffer::popData
----log_flush_set_flushed_lsn
------os_event_set(log.flush_notifier_event);
--//end while
```