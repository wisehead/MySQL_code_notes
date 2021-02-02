#1.log_write_wait_for_log

```cpp
caller:
- log_write_thread

log_write_wait_for_log
--stop_condition = [&ready_lsn, &log](bool wait)
----log_advance_ready_for_write_lsn
------Link_buf<Position>::advance_tail_until
--------Link_buf<Position>::next_position
----------index = slot_index(position);
----------&slot = m_links[index]
----------distance = slot.load()
----------next = position + distance;
--------stop_condition(position, next)//return (prev_lsn - write_lsn >= write_max_size);
----ready_lsn = log_buffer_ready_for_write_lsn(log)
```