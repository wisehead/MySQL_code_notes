#1.JOIN::optimize
```cpp
caller:
--mysql_execute_select

/**
  global select optimisation.

  @note
    error code saved in field 'error'

  @retval
    0   success
  @retval
    1   error
*/
JOIN::optimize
--JOIN::flatten_subqueries
----sj_subselects.empty()
--st_select_lex::handle_derived
--simplify_joins
--record_join_nest_info
--build_bitmap_for_nested_joins
--optimize_cond
--JOIN::optimize_fts_limit_query
--get_sort_by_table
--make_join_statistics
----TABLE_LIST::fetch_number_of_rows
------ha_innobase::info
--------ha_innobase::info_low
----------dict_table_stats_lock
----outer_join_nest
----Optimize_table_order
----JOIN::refine_best_rowcount
----JOIN::get_best_combination
--JOIN::set_access_methods
--make_join_select
----add_not_null_conds
----SQL_SELECT *sel= tab->select= new (thd->mem_root) SQL_SELECT;
----pushdown_on_conditions
--make_join_readinfo
----setup_join_buffering
--pick_table_access_method
```

#2.JOIN::exec

```cpp
caller:
--mysql_execute_select

/**
  Execute select, executor entry point.

  @todo
    When can we have here thd->net.report_error not zero?
*/
JOIN::exec
--JOIN::prepare_result
----st_select_lex::handle_derived
----select_result::prepare2
--select_send::send_result_set_metadata
----Protocol::send_result_set_metadata
--do_select
```

#3. do_select

```cpp
caller:
--do_select

/**
  Make a join of all tables and write it on socket or to table.

  @retval
    0  if ok
  @retval
    1  if error is sent
  @retval
    -1  if error should be sent
*/
do_select
--sub_select
----st_join_table::prepare_scan
----join_init_read_record
------init_read_record
```










