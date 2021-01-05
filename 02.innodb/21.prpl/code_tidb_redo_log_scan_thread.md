#1.tidb_redo_log_scan_thread

```cpp
tidb_redo_log_scan_thread
--my_thread_init
--mysql_admin_tool_set_priority
--os_event_wait(rpl_sys->m_scan_start_event);//wait for what
--start_lsn = log_translate_sn_to_lsn(rpl_sys->get_rbuf()->get_sn());
--current_lsn = log_translate_sn_to_lsn(rpl_sys->get_rbuf()->get_write_point());
--TiDB_rpl_sys::log_scan_handler
----tidb_server_create_thd//thread pool
----TiDB_DDL_Opr_Ctl::tidb_apply_meta_change_start//Apply meta data change start.
--my_thread_end
--os_thread_exit
```