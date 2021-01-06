#1.TiDB_rpl_sys::apply_log_recs

```cpp
caller:
--rpl_apply_redo_log_recs
--TiDB_rpl_sys::parse_log_recs

TiDB_rpl_sys::apply_log_recs
--header = reinterpret_cast<mtr_log_header*>(ptr);
--end_lsn = header->_lsn + header->_cpl_len;
--type = static_cast<mlog_id_t>(*(ptr + sizeof(mtr_log_header)));
--buf_page_get
--page = block->frame;
--page_lsn = mach_read_from_8(page + FIL_PAGE_LSN);
--while (ptr < end_ptr)
----parse_or_apply_log_rec_body
--//end while
--mach_write_to_8(FIL_PAGE_LSN + page, end_lsn);
--mach_write_to_8(UNIV_PAGE_SIZE- FIL_PAGE_END_LSN_OLD_CHKSUM+ page, end_lsn);
--block->page.oldest_modification = end_lsn;
```