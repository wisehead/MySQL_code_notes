#1.log_advance_ready_for_write_lsn


```cpp
caller:
--log_writer_wait_on_checkpoint
--log_writer

log_advance_ready_for_write_lsn
--log_buffer_ready_for_write_lsn
----log.recent_written.tail()
--log.recent_written.advance_tail_until(stop_condition)
----next_position
------slot_index
------next = position + distance;

```


#2.log_writer_wait_on_checkpoint