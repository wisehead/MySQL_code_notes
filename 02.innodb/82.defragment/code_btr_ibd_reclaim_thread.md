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
--log_make_latest_checkpoint
----log_make_latest_checkpoint
------log_get_lsn
```


