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
--trans_commit_stmt(thd);
--close_thread_tables
```

#2.mysql_create_table

```cpp
mysql_create_table
--open_tables
--mysql_create_table_no_lock
--write_bin_log
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
--handler::ha_create//see ha_innodb.cc..!!!!!!!!!
----ha_innobase::create
--closefrm
--free_table_share
```
