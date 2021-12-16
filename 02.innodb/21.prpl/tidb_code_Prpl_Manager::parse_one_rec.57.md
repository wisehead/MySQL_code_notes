#1.Prpl_Manager::parse_one_rec

```cpp
tidb_code_Prpl_Manager::parse_one_rec.57.MD
--switch (type)
----case MLOG_ACL_CHANGE:
----case MLOG_SP_CHANGE:
----case MLOG_META_CHANGE:
----case MLOG_TRUNCATE:
----case MLOG_NCDB_CHECKSUM:
----case MLOG_TRX_CLEAN:
------log_group->m_barrier = Log_Group::BARRIER_ELSE;
----case MLOG_DICT_STATS_UPDATE:
----case MLOG_TRX_COMP:
----case MLOG_TRX_COMMIT:
------add_to_post_list(ptr)
------break;
----case MLOG_INDEX_LOCK_ACQUIRE:
------btr_lock_acquire_parse_log
------add_to_post_list(ptr);
----default:
------add_to_hash_table
```

#2.Prpl_Manager::add_to_post_list

```cpp
Prpl_Manager::add_to_post_list
--auto rec = static_cast<rpl_rec_t *>(mem_heap_alloc(log_group->m_heap, sizeof(rpl_rec_t)));
--rec->data = ptr;
--rec->len = sizeof(mtr_log_header) + mtr_hdr->_rec_len;
--rec->multi_page = false;
--UT_LIST_ADD_LAST(log_group->m_post_recs, rec);
```