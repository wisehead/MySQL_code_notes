#1.NCDB_rpl_sys::read_log

```cpp
NCDB_rpl_sys::read_log
--os_event_wait_for(log_sys->rpl_event, 0, 1000,stop_condition);
--read_buf = m_rbuf->getData(&read_len, RECV_SCAN_SIZE)
--if (read_len > 0)
----ut_memcpy(m_buf + m_len, read_buf, read_len);
----m_len += read_len
----m_rbuf->advData(read_len);
```