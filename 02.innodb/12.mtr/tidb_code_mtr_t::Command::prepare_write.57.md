#1.mtr_t::Command::prepare_write

```cpp
mtr_t::Command::prepare_write
--if (m_impl->m_rec_checksum)
----checksum_prepare
--len = mtr_page_buf_t::size(m_impl->m_log_head);
----struct mtr_page_buf_t* it = page_buf;
----while (it)
------log_size += it->buf_size();
------it = it->next;
```