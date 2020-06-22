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
----que_run_threads_low
------que_thr_step
--------que_thr_node_step
------que_thr_step
--------dict_create_table_step
----------dict_build_table_def_step
```

#2. que_run_threads(for create table)

```cpp
que_run_threads
--que_run_threads_low
----que_thr_step
------que_thr_node_step
----que_thr_step
------dict_create_table_step
--------dict_build_table_def_step
----------dict_hdr_get_new_id//for table id
------------dict_hdr_get
----------dict_hdr_get_new_id//for space
----------fil_create_new_single_table_tablespace
----------fsp_header_init
------------fsp_init_file_page
--------------fsp_init_file_page_low
--------------mlog_write_initial_log_record(MLOG_INIT_FILE_PAGE)
------------fsp_fill_free_list
----------dict_create_sys_tables_tuple
----------ins_node_set_new_row
------------ins_node_create_entry_list
--------------row_build_index_entry
----------------row_build_index_entry_low
------------------dtuple_set_n_fields_cmp
------------row_ins_alloc_sys_fields
--------------dict_table_get_sys_col
----que_thr_step
------row_ins_step
----que_thr_step
------dict_create_table_step
```