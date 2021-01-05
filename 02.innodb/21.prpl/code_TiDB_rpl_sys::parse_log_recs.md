#1.tidb_rpl_sys::parse_log_recs

```cpp
tidb_rpl_sys::parse_log_recs
--buf_ptr = m_buf + m_recovered_offset;
--buf_len = m_len - m_recovered_offset;
--while (buf_len > sizeof(mtr_log_header))
----if (is_mtr_start)
------tidb_stats.n_apply_mtr++
------mtr_start_lsn = header->_lsn;
------mtr_end_lsn = header->_lsn + header->_cpl_len;
------set_read_lsn(mtr_end_lsn);
--//end while

```