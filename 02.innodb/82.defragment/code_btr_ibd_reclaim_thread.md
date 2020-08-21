#1.btr_ibd_reclaim_thread

```cpp
btr_ibd_reclaim_thread
--btr_reclaim_add_defragment_item
----btr_gen_defragment_item_for_db
------dict_table_get_low("SYS_TABLES")
------sys_index = UT_LIST_GET_FIRST(sys_tables->indexes)
------dtuple_create
------dfield_set_data
------dict_index_copy_types
------btr_pcur_open_on_user_rec_func
--------btr_pcur_open_low
----------btr_pcur_init
----------btr_cur_search_to_nth_level
--btr_reclaim_get_item
--btr_open_table_index
----dict_table_open_on_name
----dict_table_get_first_index
----dict_table_get_next_index
----dict_table_close
--btr_get_all_index_sx_latch
----btr_root_get
------buf_block_get_frame(btr_root_block_get(index, RW_SX_LATCH,mtr));
--space = dict_index_get_space(clust_index);
--btr_get_fsp_header
--btr_get_reclaim_page_no
--btr_load_n_pages
----btr_block_get_func
--btr_index_can_be_reclaimed
----btr_get_fseg_header
------btr_root_get
--------btr_root_block_get
----------btr_block_get
----fseg_has_enough_free_space
--get_cpu_stat
--btr_reclaim_n_pages
----xdes_get_descriptor
------xdes_get_descriptor_with_space_hdr
```

#2. btr_reclaim_n_pages

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
```

#3. btr_cur_pessimistic_delete

```cpp
btr_cur_pessimistic_delete
--btr_search_update_hash_on_delete
--page_cur_delete_rec
----page_dir_find_owner_slot
------page_dir_get_nth_slot
------rec_get_n_owned_new//找到owner record
------rec_get_next_ptr_const
------//之后根据owner record找到slot
----page_dir_get_nth_slot
----page_cur_delete_rec_write_log
------mlog_open_and_write_index
--------mlog_open
--------mlog_write_initial_log_record_fast
----------mach_write_to_1(log_ptr, type);//mlog_type
----------mach_write_compressed(log_ptr, space)
----------mach_write_compressed(log_ptr, offset);
--------mach_write_to_2(log_ptr, n);//n = dict_index_get_n_fields(index)
--------mach_write_to_2(log_ptr,dict_index_get_n_unique_in_tree(index));
--------//for (i = 0; i < n; i++)
--------mach_write_to_2(log_ptr, len);
--------//end for
------mach_write_to_2(log_ptr, page_offset(rec));
------mlog_close(mtr, log_ptr + 2);
----page_header_set_ptr(page, page_zip, PAGE_LAST_INSERT, NULL);
------page_header_set_field
----buf_block_modify_clock_inc

```
