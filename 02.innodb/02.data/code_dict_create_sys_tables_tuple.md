#1.dict_create_sys_tables_tuple

```cpp
caller:
--dict_build_table_def_step

dict_create_sys_tables_tuple
--dtuple_create
----dtuple_create_from_mem
--dict_table_copy_types
----dfield_set_null
----dict_col_copy_type
```