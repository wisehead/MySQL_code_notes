#1. btr_try_to_truncate_ibd

```cpp
btr_try_to_truncate_ibd
--btr_get_fsp_header(space, zip_size, &mtr_w);
--total_page = mach_read_from_4(header + FSP_SIZE);
--xdes_get_extent_first_page
----page_get_page_no(page_align(descr))+ ((page_offset(descr) - XDES_ARR_OFFSET) / XDES_SIZE)* FSP_EXTENT_SIZE);
--fil_set_being_extended
----fil_mutex_enter_and_prepare_for_io
------fil_space_get_by_id
----fil_space_get_by_id
----UT_LIST_GET_LAST(space->chain)
----fil_node_prepare_for_io
------fil_space_belongs_in_lru
------UT_LIST_REMOVE(LRU, system->LRU, node);
------node->n_pending++
--btr_check_freed
--btr_page_get_index_id
--r_item->index_map.find(index_id)
--btr_get_fseg_header(index, page_level, &mtr_w)
--fseg_remove_freed_extent
----flst_remove(fsp_header + FSP_FREE, descr + XDES_FLST_NODE, mtr);
--mlog_write_ulint(header + FSP_FREE_LIMIT, page_no, MLOG_4BYTES, &mtr_w);
--mlog_write_ulint(header + FSP_SIZE, page_no, MLOG_4BYTES, &mtr_w);
--buf_flush_blocks
----buf_flush_lists
----buf_flush_wait_batch_end
----log_make_checkpoint_at
--fil_flush
----fil_space_get_by_id
----fil_buffering_disabled
--fil_truncate_wrapper
----os_file_truncate
----fil_node_complete_io
```
