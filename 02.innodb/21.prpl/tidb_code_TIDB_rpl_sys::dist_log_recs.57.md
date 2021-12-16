#1.NCDB_rpl_sys::dist_log_recs

```cpp
NCDB_rpl_sys::dist_log_recs
--buf_len = m_len - m_recovered_offset;
--buf_ptr = m_buf + m_recovered_offset;
--Prpl_Manager::dist_log_recs
----swap_hash(Log_Group::TYPE_PARSE);
----m_parsing_group->copy_buffer(ptr, len);
----buf_ptr = m_parsing_group->m_buffer;
----buf_len = len;
----dist_log_recs_low(buf_ptr, buf_len);
------while (buf_len > sizeof(mtr_log_header))
--------header = reinterpret_cast<mtr_log_header*>(buf_ptr);
--------end_ptr = buf_ptr;
--------end_ptr += sizeof(mtr_log_header);
--------end_ptr += header->_rec_len;
--------if (is_mtr_start)
----------mtr_log_len = log_translate_lsn_to_sn(header->_lsn + header->_cpl_len) - log_translate_lsn_to_sn(header->_lsn);
----------if (mtr_log_len > buf_len|| log_group->m_barrier != Log_Group::BARRIER_NONE)
------------break;
----------mtr_start_lsn = header->_lsn;
----------mtr_end_lsn = header->_lsn + header->_cpl_len;
----------multi_page = header->_mtr_end_flag ? false : true;
--------prpl_mgr->parse_one_rec(buf_ptr, multi_page, mtr_end_lsn);
--------curr_rec_end_lsn = header->_lsn + header->_lsn_len;
--------rpl_sys->m_recovered_lsn = curr_rec_end_lsn;
--------rpl_sys->m_recovered_offset += end_ptr - buf_ptr;
--------buf_len -= end_ptr - buf_ptr;
--------buf_ptr += end_ptr - buf_ptr;
------log_group->m_end_lsn = mtr_end_lsn;
------log_group->m_state = Log_Group::PARSE_FINISHED;
------advance_parsing_id
------os_event_set(m_apply);
```