#1.Prpl_Worker::skip_redo_to_one_slot_low

```cpp
Prpl_Worker::skip_redo_to_one_slot_low
--for (auto rec = UT_LIST_GET_FIRST(slot->rec_list); rec != NULL;rec = UT_LIST_GET_NEXT(rec_list, rec))
----if (rec->multi_page)
------prpl_mgr->log_group_mtr_dec(mtr_end_lsn);
--prpl_mgr->log_group_page_dec(fold);
--slot->state = RECV_PROCESSED;
```