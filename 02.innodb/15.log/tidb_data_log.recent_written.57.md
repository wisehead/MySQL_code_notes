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

#5. log_buffer_write_completed

```cpp
struct mtr_parallel_write_log_t{
bool operator()(const mtr_buf_t::block_t *block)
}

struct mtr_fast_write_log_t {
bool operator()(const byte* buf, ulint len)
}
```

#6.mtr_parallel_write_log_t

```cpp
caller:
 mtr_t::Command::finish_write

```

#7. mtr_fast_write_log_t

```cpp
caller:
- mtr_t::commit_fast_finish
```

#8.mtr_t::Command::finish_write
```cpp
caller:
- mtr_t::Command::execute
- mtr_t::commit_checkpoint
```



