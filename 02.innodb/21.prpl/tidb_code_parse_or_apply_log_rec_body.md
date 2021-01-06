#1. parse_or_apply_log_rec_body

```cpp
caller:
--apply_log_recs

parse_or_apply_log_rec_body
--switch (type)//start
--case MLOG_1BYTE: case MLOG_2BYTES: case MLOG_4BYTES: case MLOG_8BYTES:
----mlog_parse_nbytes
--case MLOG_REC_INSERT: case MLOG_COMP_REC_INSERT:
----mlog_parse_index
----page_cur_parse_insert_rec
--case MLOG_REC_CLUST_DELETE_MARK: case MLOG_COMP_REC_CLUST_DELETE_MARK:
----mlog_parse_index
----btr_cur_parse_del_mark_set_clust_rec
--case MLOG_COMP_REC_SEC_DELETE_MARK:
----mlog_parse_index
--case MLOG_REC_SEC_DELETE_MARK:
----btr_cur_parse_del_mark_set_sec_rec
--case MLOG_REC_UPDATE_IN_PLACE: case MLOG_COMP_REC_UPDATE_IN_PLACE:
----mlog_parse_index
----btr_cur_parse_update_in_place
--case MLOG_LIST_END_DELETE: case MLOG_COMP_LIST_END_DELETE:
--case MLOG_LIST_START_DELETE: case MLOG_COMP_LIST_START_DELETE:
----mlog_parse_index
----page_parse_delete_rec_list
--case MLOG_LIST_END_COPY_CREATED: case MLOG_COMP_LIST_END_COPY_CREATED:
----mlog_parse_index
----page_parse_copy_rec_list_to_created_page
--case MLOG_PAGE_REORGANIZE:
--case MLOG_COMP_PAGE_REORGANIZE:
--case MLOG_ZIP_PAGE_REORGANIZE:
----mlog_parse_index
----btr_parse_page_reorganize
--case MLOG_PAGE_CREATE: case MLOG_COMP_PAGE_CREATE:
----page_parse_create
--case MLOG_PAGE_CREATE_RTREE: case MLOG_COMP_PAGE_CREATE_RTREE:
----page_parse_create(block, type == MLOG_COMP_PAGE_CREATE_RTREE,true)
--case MLOG_UNDO_INSERT:
----trx_undo_parse_add_undo_rec
--case MLOG_UNDO_ERASE_END:
----trx_undo_parse_erase_page_end
--case MLOG_UNDO_INIT:
----trx_undo_parse_page_init
--case MLOG_UNDO_HDR_DISCARD:
----trx_undo_parse_discard_latest
--case MLOG_UNDO_HDR_CREATE:
--case MLOG_UNDO_HDR_REUSE:
----trx_undo_parse_page_header
--case MLOG_REC_MIN_MARK: case MLOG_COMP_REC_MIN_MARK:
----btr_parse_set_min_rec_mark
--case MLOG_REC_DELETE: case MLOG_COMP_REC_DELETE:
----mlog_parse_index
----page_cur_parse_delete_rec
--case MLOG_IBUF_BITMAP_INIT:
----ibuf_parse_bitmap_init
--case MLOG_INIT_FILE_PAGE:
--case MLOG_INIT_FILE_PAGE2:
----fsp_parse_init_file_page
--case MLOG_WRITE_STRING:
----mlog_parse_string
--case MLOG_tidb_CHECKSUM:
----mlog_parse_tidb_checksum
--case MLOG_TRX_COMP:
----trx_apply_comp_log
--case MLOG_TRX_COMMIT:
----trx_apply_commit_log
--case MLOG_META_CHANGE:
----trx_slave_flush_ids
----ddl_opr_ctl->tidb_parse_meta_change
--case MLOG_ACL_CHANGE:
----ddl_opr_ctl->tidb_parse_acl_change
--case MLOG_SP_CHANGE:
----ddl_opr_ctl->tidb_parse_sp_change
--case MLOG_INDEX_LOCK_ACQUIRE:
----btr_lock_acquire_apply_log
--case MLOG_DICT_STATS_UPDATE:
----dict_stats_apply_log
--case MLOG_RTREE_PAGE_DISCARD:
----rtr_discard_page_apply_log
--case MLOG_TRX_CLEAN:
----trx_apply_clean_log

--//end switch
--dict_mem_index_free(index);
--dict_mem_table_free(table);

```