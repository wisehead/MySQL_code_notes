#0.log.recent_written


#1.get interface log_buffer_ready_for_write_lsn

```cpp
log_buffer_ready_for_write_lsn
--log.recent_written.tail()
```

#2.update tail

```cpp
caller:
- log_advance_ready_for_write_lsn

advance_tail_until
```

#3.has_space

```cpp
caller:
--log_buffer_write_completed
//recent_written是ring buffer，如果没有空间，log writter需要把buffer中的内容写到哪里？？？

has_space
```

#4.write data
```cpp
caller:
- log_buffer_write_completed


Link_buf<Position>::add_link
--index = slot_index(from);
--&slot = m_links[index];
--slot.store(to - from);
```