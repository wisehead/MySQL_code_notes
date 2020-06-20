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