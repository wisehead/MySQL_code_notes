#1.Prpl_Worker::apply_redo_to_one_slot_low

```cpp
Prpl_Worker::apply_redo_to_one_slot_low
--for (auto rec = UT_LIST_GET_FIRST(slot->rec_list); rec != NULL;rec = UT_LIST_GET_NEXT(rec_list, rec))
----mtr_hdr = reinterpret_cast<mtr_log_header*>(rec->data);
----mtr_end_lsn = mtr_hdr->_lsn + mtr_hdr->_cpl_len;
----buf_page_get_known_nowait
----NCDB_rpl_sys::apply_log_recs
----if (rec->multi_page)
------prpl_mgr->log_group_mtr_dec(mtr_end_lsn);
--------m_applying_group->m_mtrs.slot_dec(mtr_end_lsn);
--slot->state = RECV_PROCESSED;
```