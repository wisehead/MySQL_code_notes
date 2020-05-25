#1.pars_sql

```cpp
dict_stats_fetch_from_ps
--dict_stats_empty_table
--trx_allocate_for_background
----trx_create_low
--trx_start_internal_low
----trx_start_low
--pars_info_create
--pars_info_add_str_literal
----pars_info_add_literal
--pars_info_bind_function
----callback is dict_stats_fetch_table_stats_step
--que_eval_sql//innodb内部调用sql 的方法
----pars_sql
------yyparse
--------pars_select_statement
----------pars_retrieve_table_list_defs
------------pars_retrieve_table_def
--------------dict_table_open_on_name
----que_fork_start_command
------que_thr_init_command
--------que_thr_move_to_run_state	
----que_run_threads
------que_run_threads_low
--------que_thr_step
----------que_thr_node_step
```