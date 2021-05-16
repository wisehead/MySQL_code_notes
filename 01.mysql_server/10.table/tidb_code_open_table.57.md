#1.open_table

```cpp
open_table
--get_table_def_key//mdl key, dbname+tablename
--open_table_get_mdl_lock
--hash_value= my_calc_hash(&table_def_cache, (uchar*) key, key_length)
--Table_cache *tc= table_cache_manager.get_cache(thd);



```

#2 caller

```cpp
mysql_execute_command
--execute_sqlcom_select
----open_tables_for_query
------open_tables
--------open_and_process_table
----------open_table
```