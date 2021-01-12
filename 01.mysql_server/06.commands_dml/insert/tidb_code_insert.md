#1.mysql\_execute\_command

```cpp
mysql_execute_command
--Sql_cmd_insert::execute
----open_temporary_tables
----insert_precheck
----Sql_cmd_insert::mysql_insert
------open_tables_for_query
--------open_tables
----------lock_table_names
----------open_and_process_table
------------open_table
--------------get_table_def_key
--------------open_table_get_mdl_lock
--------------Table_cache::get_table
```