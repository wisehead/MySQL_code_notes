#1.recent_written in log_t

```cpp
- log_buffer_ready_for_write_lsn
- log_advance_ready_for_write_lsn
- log_buffer_write_completed
- recv_reset_logs
```

#2. log_buffer_ready_for_write_lsn

```cpp
log_buffer_ready_for_write_lsn
--log.recent_written.tail()
----m_tail.load();//ut0link_buf.h

```