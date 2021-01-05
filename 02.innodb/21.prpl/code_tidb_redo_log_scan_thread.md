#1.tidb_redo_log_scan_thread

```cpp
tidb_redo_log_scan_thread
--mysql_admin_tool_set_priority
--os_event_wait(rpl_sys->m_scan_start_event);//wait for what
--start_lsn = log_translate_sn_to_lsn(rpl_sys->get_rbuf()->get_sn());
--current_lsn = log_translate_sn_to_lsn(rpl_sys->get_rbuf()->get_write_point());
--my_thread_end
--os_thread_exit
```