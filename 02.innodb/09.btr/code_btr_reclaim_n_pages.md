#1. btr_reclaim_n_pages

```cpp
btr_reclaim_n_pages
--//if (descr == NULL)
--//else if (page_type == FIL_PAGE_TYPE_ALLOCATED)
--//else if (page_type == FIL_PAGE_INDEX)
--btr_get_first_free_page_no
----fseg_smallest_free_page_no
------fseg_inode_get
--------inode_addr.page = mach_read_from_4(header + FSEG_HDR_PAGE_NO);
--------inode_addr.boffset = mach_read_from_2(header + FSEG_HDR_OFFSET);
--------fut_get_ptr
------flst_get_first(seg_inode + FSEG_NOT_FULL, mtr2);
------xdes_lst_get_descriptor
--------fut_get_ptr
------xdes_get_offset
------xdes_find_bit
------flst_get_next_addr
--------flst_read_addr(node + FLST_NEXT, mtr)
--btr_page_alloc
--btr_page_create
----page_create
------page_create_low
------mach_write_to_2(PAGE_HEADER + PAGE_LEVEL + page, level);
------mach_write_to_8(PAGE_HEADER + PAGE_MAX_TRX_ID + page, max_trx_id);
----btr_page_set_index_id(page, page_zip, index->id, mtr);
--btr_attach_half_pages
--page_copy_rec_list_end
----lock_move_rec_list_end
--btr_search_move_or_delete_hash_entries
--lock_update_merge_left
----lock_rec_inherit_to_gap
------lock_rec_get_first
----lock_rec_reset_and_release_wait
----lock_rec_move
------lock_rec_get_first
--------lock_rec_get_first_on_page
----lock_rec_free_all_from_discard_page
------lock_rec_get_first_on_page_addr
--btr_search_drop_page_hash_index
--btr_level_list_remove_func
--btr_node_ptr_delete
----btr_page_get_father
----btr_cur_pessimistic_delete
----btr_cur_compress_if_useful
------btr_cur_compress_recommendation
------btr_compress
--btr_page_free

```