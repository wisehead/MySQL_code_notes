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
----tidb_trx_sys_update_thread
----read_buf = m_rbuf->getData(&read_len, RECV_SCAN_SIZE);
----ut_memcpy(m_buf + m_len, read_buf, read_len);
----m_len += read_len;
----m_rbuf->advData(read_len);
----recv_calc_lsn_on_data_add
----parse_log_recs
----justify_left_parsing_buf/* Move parsing buffer data to the buffer start */
----m_rbuf->popData(m_recovered_lsn);/* Pop data from ring buffer */
--my_thread_end
--os_thread_exit
```