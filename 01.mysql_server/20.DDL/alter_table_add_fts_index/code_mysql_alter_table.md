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
--mysql_inplace_alter_table
----handler::ha_prepare_inplace_alter_table
------ha_innobase::prepare_inplace_alter_table
--------ha_innobase::prepare_inplace_alter_table_impl<dd::Table>
----------prepare_inplace_alter_table_dict<dd::Table>
------------fts_create_index_tables
----handler::ha_inplace_alter_table
------ha_innobase::inplace_alter_table
--------ha_innobase::inplace_alter_table_impl<dd::Table>
----------row_merge_build_indexes
------------row_merge_read_clustered_index
--------------fts_sync_table
----------------fts_sync
------------------fts_sync_index
--------------------fts_sync_write_words
----------------------fts_write_node
------------------------fts_eval_sql
--------------------------que_run_threads
----------------------------que_run_threads_low
------------------------------que_thr_step
--------------------------------row_ins_step
----------------------------------row_ins
------------------------------------row_ins_index_entry_step
--------------------------------------row_ins_index_entry
----------------------------------------row_ins_clust_index_entry
------------------------------------------row_ins_clust_index_entry_low
--------------------------------------------btr_cur_optimistic_insert
----------------------------------------------page_cur_tuple_insert
------------------------------------------------page_cur_insert_rec_low
```

#2.