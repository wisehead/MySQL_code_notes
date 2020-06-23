#1. row_create_table_for_mysql

```cpp
row_create_table_for_mysql
--trx_start_if_not_started_xa_low
----thd_supports_xa
------mysql_sys_var_char
--------intern_sys_var_ptr
----trx_start_low
------trx->id = trx_sys_get_new_trx_id();
------trx_sys->rw_trx_ids.push_back(trx->id);
------trx_sys->rw_trx_set.insert(TrxTrack(trx->id, trx));
------UT_LIST_ADD_FIRST(trx_list, trx_sys->rw_trx_list, trx);
--trx_set_dict_operation
--tab_create_graph_create
----ins_node_create
--pars_complete_graph_for_exec
----que_fork_create
----que_thr_create
------UT_LIST_ADD_LAST(thrs, parent->thrs, thr);
--que_fork_start_command
----que_thr_init_command
------que_thr_move_to_run_state
--que_run_threads
--dict_create_add_tablespace_to_dictionary
----que_eval_sql(info,
                 "PROCEDURE P () IS\n"
                 "BEGIN\n"
                 "INSERT INTO SYS_TABLESPACES VALUES"
                 "(:space, :name, :flags);\n"
                 "INSERT INTO SYS_DATAFILES VALUES"
                 "(:space, :path);\n"
                 "END;\n",
                 FALSE, trx);
--que_graph_free
```