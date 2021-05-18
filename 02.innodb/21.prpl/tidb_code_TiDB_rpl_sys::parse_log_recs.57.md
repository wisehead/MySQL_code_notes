#1.tidb_rpl_sys::parse_log_recs

```cpp
tidb_rpl_sys::parse_log_recs
--buf_ptr = m_buf + m_recovered_offset;
--buf_len = m_len - m_recovered_offset;
--while (buf_len > sizeof(mtr_log_header))
----if (is_mtr_start)
------tidb_stats.n_apply_mtr++
------mtr_start_lsn = header->_lsn;
------mtr_end_lsn = header->_lsn + header->_cpl_len;
------set_read_lsn(mtr_end_lsn);
----end_ptr += sizeof(mtr_log_header);
----end_ptr += header->_rec_len;
----if (header->_mtr_end_flag)
------is_mtr_end = true;
----mtr_start(&mtr);
----mtr_set_log_mode(&mtr, MTR_LOG_NONE);
----/* Handle different states of the page:
               1. page is not in buffer pool: skip the log;
               2. page is in buffer pool, io_fix is :
                  a. BUF_IO_NONE: apply the log directly;
                  b. BUF_IO_READ: add the log into block log list,
                 and apply it when io complete.
            Note: In case 2.b, if io thread has been applying log
            of the page(not yet to change io_fix to BUF_IO_NONE,
            do not add the log into block log list, but apply it here.*/
----buf_page_peek_for_apply
------buf_page_hash_get_low
--------HASH_SEARCH(hash, buf_pool->page_hash, page_id.fold(), buf_page_t*,bpage
------if (buf_page_get_io_fix(bpage) == BUF_IO_READ)
--------rpl_add_redo_log_rec
----------memcpy(rpl_rec->data, rec->data, rec->len);
----------UT_LIST_ADD_LAST(rpl_addr->rec_list, rpl_rec);
----apply_log_recs
----mtr.discard_modifications
----mtr_commit(&mtr);
----if (is_mtr_end)
------set_applied_lsn(mtr_end_lsn);
------buf_shm_set_applied_lsn(mtr_end_lsn);
------if (m_lock_acquire_index != NULL)
--------/* Release index lock and load index ssn for rtree index. */
--------dict_table_close(index->table, TRUE, FALSE);
----end_lsn = header->_lsn + header->_lsn_len;
----m_recovered_lsn = end_lsn;
----m_recovered_offset += end_ptr - buf_ptr;
----buf_len = m_len - m_recovered_offset;
----buf_ptr = m_buf + m_recovered_offset;
----update_rpl_lag(end_lsn);
------m_sync_info.update_info(lsn);
----release_locks(thd, end_lsn);//TiDB_rpl_sys::release_locks
------ncdb_apply_meta_clear
--------ddl_table_set.clear();
------ncdb_release_all_mdls
--------thd->mdl_context.release_explicit_locks()
------m_recv_ddl_lsn = 0;
--//end while
--/* Update some lsn in log_sys */
    log_sys->flushed_to_disk_lsn = m_recovered_lsn;
    log_sys->sn = log_translate_lsn_to_sn(m_recovered_lsn);
    log_sys->lsn = m_recovered_lsn;
    log_sys->write_lsn = m_recovered_lsn;
    log_sys->next_checkpoint_lsn = m_recovered_lsn;
    log_sys->last_checkpoint_lsn = m_recovered_lsn;


```