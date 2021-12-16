#1.Prpl_Manager::add_to_hash_table

```cpp
Prpl_Manager::add_to_hash_table
--mtr_hdr = reinterpret_cast<mtr_log_header*>(ptr);
--auto space_iter = spaces->find(space_id);
--space = &space_iter->second;
--rec = static_cast<rpl_rec_t *>(mem_heap_alloc(space->m_heap,sizeof(rpl_rec_t)));
--rec->data = ptr;
--rec->multi_page = multi_page;
--rec->len = sizeof(mtr_log_header) + mtr_hdr->_rec_len;
--auto slot_iter = space->m_pages.find(page_no);
--slot = slot_iter->second;
--UT_LIST_ADD_LAST(slot->rec_list, rec);
--if (multi_page)
----log_group_mtr_inc(mtr_end_lsn);
```