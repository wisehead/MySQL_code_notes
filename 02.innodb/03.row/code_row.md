#1.row_search_for_mysql

```cpp
caller:
--general_fetch

row_search_for_mysql
--dict_index_is_corrupted
--mtr_start(&mtr);
--trx_start_if_not_started
----trx_start_if_not_started_low
--que_fork_get_first_thr
----UT_LIST_GET_FIRST
------fork->thrs.start
--que_thr_move_to_run_state_for_mysql
--sel_restore_position_for_mysql
--btr_pcur_move_to_next
--btr_pcur_get_rec
----btr_pcur_get_btr_cur
----btr_cur_get_rec
------page_cur_get_rec
--rec_get_offsets_func
----dict_index_get_n_fields
----rec_offs_set_n_fields
----rec_init_offsets
------rec_init_offsets_comp_ordinary
--lock_clust_rec_cons_read_sees
--rec_get_deleted_flag
----rec_get_bit_field_1
----REC_NEW_INFO_BITS = 5, REC_INFO_DELETED_FLAG = 0x20UL, REC_INFO_BITS_SHIFT = 0
--row_search_idx_cond_check
--row_sel_store_mysql_rec
--row_sel_store_row_id_to_prebuilt
----dict_index_get_sys_col_pos
------dict_table_get_sys_col
------dict_col_get_clust_pos
----rec_get_nth_field
--btr_pcur_store_position
--que_thr_stop_for_mysql_no_error
--mtr_commit(&mtr)
```

#2.sel_restore_position_for_mysql

```cpp
caller:
--row_search_for_mysql

sel_restore_position_for_mysql
--btr_pcur_restore_position_func
----buf_page_optimistic_get
------buf_page_set_accessed
------buf_page_make_young_if_needed
--------buf_page_peek_if_too_old
------rw_lock_s_lock_nowait
------mtr_memo_push
--------slot = (mtr_memo_slot_t*) dyn_array_push(memo, sizeof *slot);
```

#3.row_sel_store_mysql_rec

```cpp
caller:
--row_search_for_mysql

row_sel_store_mysql_rec
--row_sel_store_mysql_field_func
----rec_get_nth_field
------rec_get_nth_field_offs
----row_sel_field_store_in_mysql_format_func
```