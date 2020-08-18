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
----btr_page_alloc_low
------fseg_alloc_free_page_general
--------fseg_inode_get
--------fseg_alloc_free_page_low
----------xdes_get_descriptor_with_space_hdr
------------xdes_calc_descriptor_page
----------fseg_mark_page_used
----------fsp_page_create
------------buf_page_create
--------------buf_LRU_get_free_block
--------------buf_page_hash_get_low
--------------buf_page_init
--------------buf_LRU_add_block
--------------memset(frame + FIL_PAGE_PREV, 0xff, 4);
--------------memset(frame + FIL_PAGE_NEXT, 0xff, 4);
--------------mach_write_to_2(frame + FIL_PAGE_TYPE, FIL_PAGE_TYPE_ALLOCATED);
--------------memset(frame + FIL_PAGE_FILE_FLUSH_LSN, 0, 8);
------------fsp_init_file_page
--------------fsp_init_file_page_low
----------------memset(page, 0, UNIV_PAGE_SIZE);
----------------mach_write_to_4(page + FIL_PAGE_OFFSET, buf_block_get_page_no(block));
----------------mach_write_to_4(page + FIL_PAGE_ARCH_LOG_NO_OR_SPACE_ID,buf_block_get_space(block));
--------------mlog_write_initial_log_record(MLOG_INIT_FILE_PAGE)
```