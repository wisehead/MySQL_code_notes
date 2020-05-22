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
--que_thr_move_to_run_state_for_mysql
```