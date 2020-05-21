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
```