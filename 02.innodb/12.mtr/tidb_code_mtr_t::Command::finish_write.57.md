#1.mtr_t::Command::finish_write

```cpp
mtr_t::Command::finish_write
--mtr_page_buf_t* it = m_impl->m_log_head;
--Log_handle      handle = log_buffer_reserve(log, len);
--m_start_lsn = handle.start_lsn;
--m_end_lsn = handle.end_lsn;
--log_sn = log_translate_lsn_to_sn(m_start_lsn);
--if (m_impl->m_multi_type == MTR_MULTI_BTR)
----ssn_finish(m_end_lsn)
------mtr_page_buf_t*         it = m_impl->m_log_head;
------while (it)
--------mach_write_to_8(it->ssn_ptr, end_lsn);
--------it = it->next;
--while (it)
----mtr_buf_t*      log_buf = &it->log_buf;
----page_len = log_buf->size();
----page_start_lsn = log_translate_sn_to_lsn(log_sn);
----log_sn += page_len;
----finish_write_header
----log_buf->for_each_block(write_log);
------start_lsn = m_lsn;
------end_lsn = log_buffer_write
------m_left_to_write -= block->used();
------if (m_left_to_write == 0 && m_rec_group_start_lsn / OS_FILE_LOG_BLOCK_SIZE !=end_lsn / OS_FILE_LOG_BLOCK_SIZE)
--------log_buffer_set_first_record_group
------log_buffer_write_completed
------m_lsn = end_lsn;
----it = it->next;
--log_buffer_close(log, handle);

```


#2.一些概念小结

```cpp
                finish_write_header(it,
                                    page_start_lsn,//start_lsn, 这个页开始的lsn
                                    log_translate_sn_to_lsn(log_sn) - page_start_lsn,//lsn_len, 这个页相关的log size
                                    m_end_lsn - page_start_lsn,//cpl_len ，mtr剩余的log size
                                    !it->next);
   finish_write_header(
        mtr_page_buf_t* it,
        lsn_t           start_lsn,
        ulint           lsn_len,
        ulint           cpl_len,
        bool            is_end)     
```