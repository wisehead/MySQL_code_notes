#1. mysql_alter_table

```cpp
caller：
mysql_execute_command
--Sql_cmd_alter_table::execute
----mysql_alter_table

mysql_alter_table
--open_tables
----lock_table_names
------get_and_lock_tablespace_names
--------dd::fill_table_and_parts_tablespace_names
--------lock_tablespace_names
----open_and_process_table
------open_table
--------get_table_def_key
--------open_table_get_mdl_lock
----------MDL_context::acquire_lock
--------Table_cache::get_table
--------TABLE::init
------check_and_update_table_version
--mysql_prepare_alter_table
----prepare_fields_and_keys
----ha_innobase::update_create_info
--MDL_EXCLUSIVE Lock
--create_table_impl
----check_engine
----get_new_handler
------innobase_create_handler
----check_if_table_exists
------ha_table_exists_in_engine
--------plugin_foreach
----mysql_prepare_create_table
----rea_create_base_table
--fill_alter_inplace_info
--open_table_uncached
----create_table_def_key_tmp
------create_table_def_key
----init_tmp_table_share
----open_table_def
------fill_share_from_dd
--------ha_resolve_by_name_raw
----------plugin_lock_by_name
------------plugin_find_internal
--------fill_tablespace_from_dd
------fill_indexes_from_dd
--------fill_index_from_dd
--------fill_index_elements_from_dd
----------fill_index_element_from_dd
------fill_columns_from_dd
------prepare_share
--------get_new_handler
----------innobase_create_handler
--------setup_key_part_field
--------destroy(handler_file)
------get_table_category
----open_table_from_share
------handler::change_table_ptr
--update_altered_table
--ha_innobase::check_if_supported_inplace_alter
----innobase_support_instant
//!!!!!!!!!!!!!!!!!!!!!!!!
--mysql_inplace_alter_table
----thd->mdl_context.upgrade_shared_lock(table->mdl_ticket, MDL_EXCLUSIVE
----tdc_remove_table//将原表(名字表)从tdc中删除
------create_table_def_key
------table_def_cache->find
------remove_table(it);
----lock_tables
------mysql_lock_tables
----handler::ha_prepare_inplace_alter_table
------mark_trx_read_write
------ha_innobase::prepare_inplace_alter_table
--------ha_innobase::prepare_inplace_alter_table_impl<dd::Table>
----------innobase_index_name_is_reserved
----------innobase_fts_check_doc_id_col
----------innobase_fts_check_doc_id_index
----------prepare_inplace_alter_table_dict<dd::Table>
------------innobase_create_key_defs<dd::Table>
--------------innobase_create_index_def<dd::Table>
----------------innobase_create_index_field_def
------------row_merge_lock_table
--------------lock_table_for_trx
------------row_mysql_lock_data_dictionary_func
------------online_retry_drop_dict_indexes
------------row_merge_create_index
--------------dict_mem_index_create
--------------dict_build_index_def
--------------dict_index_add_to_cache_w_vcol
------------fts_create_index_tables
------------fts_freeze_aux_tables
--------------dict_table_prevent_eviction
----------------dict_table_move_from_lru_to_non_lru
------------dd_prepare_inplace_alter_table<dd::Table>
------------fts_create_index_dd_tables
--------------fts_create_one_index_dd_tables
----------------dd_create_fts_index_table
------------------dd_write_table<dd::Table>
--------------------dd_write_index<dd::Index>
------------fts_detach_aux_tables
//"hi/fts_", '0' <repeats 13 times>, "499_being_deleted"
//"hi/fts_", '0' <repeats 13 times>, "499_being_deleted_cache"
//"hi/fts_", '0' <repeats 13 times>, "499_config"
//"hi/fts_", '0' <repeats 13 times>, "499_deleted"
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "119_index_1
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "119_index_2
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "119_index_3
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "119_index_4
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "119_index_5
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "119_index_6
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "126_index_1
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "126_index_2
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "126_index_3
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "126_index_4
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "12d_index_1
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "12d_index_2
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "12d_index_3
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "12d_index_4
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "12d_index_5
//"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "12d_index_6
----table->mdl_ticket->downgrade_lock(MDL_SHARED_NO_WRITE);//之前是X
----handler::ha_inplace_alter_table
------ha_innobase::inplace_alter_table
--------ha_innobase::inplace_alter_table_impl<dd::Table>
----------row_merge_build_indexes
```
