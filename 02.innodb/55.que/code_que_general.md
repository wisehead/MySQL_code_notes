#1. que_eval_sql

```cpp
caller:
--innodb内部sql。

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

#2.query graph的几个用途

```cpp
1.修改元数据，用存储过程的形式，修改内部系统表数据。
2.
```