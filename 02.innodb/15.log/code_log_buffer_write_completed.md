#1.log_buffer_write_completed

```cpp
caller:
btr_defragment_thread
--mtr_commit
----mtr_log_reserve_and_write
------mtr_log_buffer_write
--------log_buffer_write_completed

log_buffer_write_completed
--log.recent_written.has_space(start_lsn)
----tail() + m_capacity > position;
```