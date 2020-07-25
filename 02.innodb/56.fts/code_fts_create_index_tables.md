#1. fts_create_index_tables

##1.1 caller stack
```cpp
mysql_execute_command
--Sql_cmd_alter_table::execute
----mysql_alter_table
------mysql_inplace_alter_table
--------handler::ha_prepare_inplace_alter_table
----------ha_innobase::prepare_inplace_alter_table
------------ha_innobase::prepare_inplace_alter_table_impl<dd::Table>
--------------prepare_inplace_alter_table_dict<dd::Table>
----------------fts_create_index_tables
--------handler::ha_inplace_alter_table
```

##1.2 fts_create_index_tables

```cpp
fts_create_index_tables
--fts_create_index_tables_low
----fts_create_one_index_table
------row_create_index_for_mysql
--------dict_create_index_tree_in_mem
----------btr_create
------------page_create
--------------page_create_low
```