#1.dict_build_col_def_step

```cpp
//信息插入SYS_COLUMNS table
dict_build_col_def_step
--dict_create_sys_columns_tuple
--ins_node_set_new_row
----ins_node_create_entry_list
------row_build_index_entry
----row_ins_alloc_sys_fields

```