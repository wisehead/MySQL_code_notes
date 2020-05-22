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