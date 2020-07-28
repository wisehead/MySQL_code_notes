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
--dd_table_open_on_name_in_mem
----dict_table_check_if_in_cache_low
--fts_create_index_tables_low
----fts_create_one_index_table//name = hi/fts_
//name = {m_name = 0x7ff694164f18 "hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "134_index_3"}
------fts_create_in_mem_aux_table
------dict_mem_table_create
------dict_mem_table_add_col("word")
------dict_mem_table_add_col("first_doc_id"
------dict_mem_table_add_col(new_table, heap, "last_doc_id"
------dict_mem_table_add_col(new_table, heap, "doc_count"
------dict_mem_table_add_col(new_table, heap, "ilist", DATA_BLOB,
------row_create_index_for_mysql
--------dict_create_index_tree_in_mem
----------btr_create
------------page_create
--------------page_create_low
------dict_mem_index_create
------index->add_field("word", 0, true);
------index->add_field("first_doc_id", 0, true);
------row_create_index_for_mysql
```

##1.3 fts index name

```cpp
"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "134_index_1
"hi/fts_", '0' <repeats 13 times>, "499_", '0' <repeats 13 times>, "134_index_3"

```