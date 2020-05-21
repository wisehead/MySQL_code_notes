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
----rr_sequential
----evaluate_join_record
------end_send
--------select_send::send_data
----------Protocol::send_result_set_row
```

#4.todo work.

```cpp
(gdb) bt
#0  Protocol::send_result_set_row (this=this@entry=0x16a4460, row_items=row_items@entry=0x16a6938) at /home/chenhui/mysql-5623-trunk/sql/protocol.cc:838
#1  0x00000000006b3d61 in select_send::send_data (this=0x7ffed80074d8, items=...) at /home/chenhui/mysql-5623-trunk/sql/sql_class.cc:2515
#2  0x00000000006c9ac8 in end_send (join=0x7ffed8007500, join_tab=0x7ffed80085d8, end_of_records=<optimized out>) at /home/chenhui/mysql-5623-trunk/sql/sql_executor.cc:2776
#3  0x00000000006cd52b in evaluate_join_record (join=join@entry=0x7ffed8007500, join_tab=join_tab@entry=0x7ffed80082d8) at /home/chenhui/mysql-5623-trunk/sql/sql_executor.cc:1601
#4  0x00000000006cd889 in sub_select (join=0x7ffed8007500, join_tab=0x7ffed80082d8, end_of_records=<optimized out>) at /home/chenhui/mysql-5623-trunk/sql/sql_executor.cc:1276
#5  0x00000000006cbb03 in do_select (join=0x7ffed8007500) at /home/chenhui/mysql-5623-trunk/sql/sql_executor.cc:933
#6  JOIN::exec (this=0x7ffed8007500) at /home/chenhui/mysql-5623-trunk/sql/sql_executor.cc:194
#7  0x00000000007121f5 in mysql_execute_select (free_join=true, select_lex=0x16a6818, thd=0x16a3f80) at /home/chenhui/mysql-5623-trunk/sql/sql_select.cc:1100
#8  mysql_select (thd=thd@entry=0x16a3f80, tables=0x7ffed8006ec0, wild_num=1, fields=..., conds=0x0, order=order@entry=0x16a69e0, group=group@entry=0x16a6918, having=0x0, select_options=2147748608, result=result@entry=0x7ffed80074d8, unit=unit@entry=0x16a61d0,
    select_lex=select_lex@entry=0x16a6818) at /home/chenhui/mysql-5623-trunk/sql/sql_select.cc:1221
#9  0x0000000000712adc in handle_select (thd=thd@entry=0x16a3f80, result=result@entry=0x7ffed80074d8, setup_tables_done_option=setup_tables_done_option@entry=0) at /home/chenhui/mysql-5623-trunk/sql/sql_select.cc:110
#10 0x0000000000578ea1 in execute_sqlcom_select (thd=thd@entry=0x16a3f80, all_tables=<optimized out>) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:5271
#11 0x00000000006f2b0c in mysql_execute_command (thd=thd@entry=0x16a3f80) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:2749
#12 0x00000000006f66d8 in mysql_parse (thd=thd@entry=0x16a3f80, rawbuf=<optimized out>, length=<optimized out>, parser_state=parser_state@entry=0x7fffa4588770) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:6549
#13 0x00000000006f7c32 in dispatch_command (command=COM_QUERY, thd=0x16a3f80, packet=<optimized out>, packet_length=<optimized out>) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:1339
#14 0x00000000006f99d6 in do_command (thd=<optimized out>) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:1037
#15 0x00000000006c0d2d in do_handle_one_connection (thd_arg=thd_arg@entry=0x16a3f80) at /home/chenhui/mysql-5623-trunk/sql/sql_connect.cc:982
#16 0x00000000006c0d78 in handle_one_connection (arg=arg@entry=0x16a3f80) at /home/chenhui/mysql-5623-trunk/sql/sql_connect.cc:898
#17 0x0000000000b48443 in pfs_spawn_thread (arg=0x16eafc0) at /home/chenhui/mysql-5623-trunk/storage/perfschema/pfs.cc:1860
#18 0x00007ffff7bc61c3 in start_thread () from /opt/compiler/gcc-4.8.2/lib/libpthread.so.0
#19 0x00007ffff6ca112d in clone () from /opt/compiler/gcc-4.8.2/lib/libc.so.6
```









