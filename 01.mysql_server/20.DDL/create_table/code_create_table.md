#1.mysql_execute_command

```
mysql_execute_command
--mysql_ha_rm_tables
--open_temporary_tables
----open_temporary_table 
--//lex->sql_command = SQLCOM_CREATE_TABLE
--create_table_precheck
----check_access
----check_grant
--append_file_to_dir
--mysql_create_table
```

#2.mysql_create_table

```cpp
mysql_create_table
--open_tables
--mysql_create_table_no_lock
```

#3. open_tables

```cpp
open_tables
--lock_table_names
----mdl_requests.push_front(&table->mdl_request);//(MDL_SHARED)
----schema_request->init(MDL_key::SCHEMA, table->db, "",MDL_INTENTION_EXCLUSIVE,MDL_TRANSACTION);
----global_request.init(MDL_key::GLOBAL, "", "", MDL_INTENTION_EXCLUSIVE,MDL_STATEMENT);
--open_and_process_table
```

#4. open_and_process_table

```cpp
open_and_process_table
--open_table
----get_table_def_key
----open_table_get_mdl_lock
----check_if_table_exists
------build_table_filename
------ha_check_if_table_exists
--------ha_discover
----------plugin_foreach_with_mask
------------discover_handlerton
----MDL_context::upgrade_shared_lock
```

#5.create_table_impl

```cpp
caller:
--mysql_create_table_no_lock

create_table_impl
--check_engine
----ha_checktype
------ha_resolve_by_legacy_type
--------ha_lock_engine
----------plugin_lock
------------intern_plugin_lock
----ha_check_if_supported_system_table
--set_table_default_charset
----load_db_opt_by_name
------load_db_opt
--------get_dbopt
--get_new_handler
----innobase_create_handler
----handler::init
--mysql_prepare_create_table
----check_column_name
----prepare_create_field
----check_string_char_length
--get_cached_table_share
--ha_table_exists_in_engine
--rea_create_table//create frm
----mysql_create_frm
----handler::ha_create_handler_files
------handler::create_handler_files
----ha_create_table
```


#6. mysql_create_frm

```cpp
mysql_create_frm
--create_frm
----inline_mysql_file_create
------my_create
--make_new_entry
----inline_mysql_file_chsize
--make_empty_rec	
----make_field
----Field::init
--inline_mysql_file_sync
```

#7.ha_create_table

```cpp
ha_create_table
--init_tmp_table_share
--open_table_def
----inline_mysql_file_open
----mysql_file_read
----open_binary_frm
------mysql_file_read(file, forminfo,288,MYF(MY_NABP))
------handler::set_ha_share_ref
------make_field
----get_table_category
--get_table_share_v1
----find_or_create_table_share
--open_table_from_share
----get_new_handler
--handler::ha_create
----ha_innobase::create
--closefrm
--free_table_share
```

#8.ha_innobase::create

```cpp
ha_innobase::create
--create_options_are_invalid
--innobase_table_flags
--innobase_index_name_is_reserved
--check_trx_exists
----thd_to_trx
------thd_ha_data
----innobase_trx_init
--innobase_trx_allocate
----trx_allocate_for_mysql
------trx_allocate_for_background
--------trx_create_low
----------PoolManager<Pool<trx_t, TrxFactory, TrxPoolLock>, TrxPoolManagerLock>::get
------------Pool<trx_t, TrxFactory, TrxPoolLock>::get
------UT_LIST_ADD_FIRST(mysql_trx_list, trx_sys->mysql_trx_list, trx);
----innobase_trx_init
--create_table_def
--create_index
--innobase_get_stmt
--row_table_add_foreign_constraints
----dict_create_foreign_constraints
------dict_create_foreign_constraints_low
--innobase_commit_low
--log_buffer_flush_to_disk
--innobase_copy_frm_flags_from_create_info
--dict_stats_update
----dict_stats_save
------dict_stats_exec_sql
--------que_eval_sql
--dict_table_close
--trx_free_for_mysql
```

#9. create_table_def

```cpp
create_table_def
--create_table_check_doc_id_col
----dict_mem_table_create
--dict_mem_table_add_col
----dict_add_col_name
--row_create_table_for_mysql
```

#10. row_create_table_for_mysql

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
```

#11. create_index

```cpp
create_index
--dict_mem_index_create
----dict_mem_fill_index_struct
--dict_mem_index_add_field
--row_create_index_for_mysql
```

#12.row_create_index_for_mysql

```cpp
row_create_index_for_mysql
--dict_table_open_on_name
----dict_table_check_if_in_cache_low
--dict_move_to_mru
--trx_set_dict_operation
--ind_create_graph_create
----trx_commit_node_create
--pars_complete_graph_for_exec
----que_fork_create
----que_thr_create
--que_fork_start_command
--que_run_threads
----que_run_threads_low
------que_thr_step//QUE_NODE_THR == 9
--------que_thr_node_step
------que_thr_step//QUE_NODE_CREATE_INDEX == 15
--------dict_create_index_step
------que_thr_step//QUE_NODE_INSERT == 2
--------row_ins_step
------que_thr_step// QUE_NODE_CREATE_INDEX == 15
--------dict_create_index_step//node->state == INDEX_BUILD_FIELD_DEF
----------dict_build_field_def_step
------que_thr_step//QUE_NODE_INSERT == 2
--------row_ins_step
------que_thr_step// QUE_NODE_CREATE_INDEX == 15
--------dict_create_index_step//node->state == INDEX_BUILD_FIELD_DEF
----------node->state = INDEX_ADD_TO_CACHE;
----------dict_index_add_to_cache
----------node->state = INDEX_CREATE_INDEX_TREE
----------dict_create_index_tree_step
----------node->state = INDEX_COMMIT_WORK;
----------node->state = INDEX_CREATE_INDEX_TREE;
------que_thr_step//QUE_NODE_THR == 9
--------que_thr_node_step
----------thr->state = QUE_THR_COMPLETED;
--que_graph_free
--dict_table_close
```

#13. dict_create_index_step

```cpp
dict_create_index_step
--dict_build_index_def_step
----dict_hdr_get_new_id//for index
----dict_create_sys_indexes_tuple
----ins_node_set_new_row
```

#14.dict_build_field_def_step

```cpp
dict_build_field_def_step
--dict_create_sys_fields_tuple
--ins_node_set_new_row
```

#15.dict_create_index_tree_step

```cpp
dict_create_index_tree_step
--dict_create_search_tuple
--btr_pcur_open_low
--btr_pcur_move_to_next_user_rec
----btr_pcur_move_to_next_on_page
------page_cur_move_to_next
--------page_rec_get_next
----------page_rec_is_comp
----------page_rec_get_next_low
------------rec_get_next_offs
--btr_create
--btr_pcur_close
```

#16.
