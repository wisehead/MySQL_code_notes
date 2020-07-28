#1.row_merge_build_indexes

#1.1 caller
```cpp
mysql_alter_table
--mysql_inplace_alter_table
----handler::ha_inplace_alter_table
------ha_innobase::inplace_alter_table
--------ha_innobase::inplace_alter_table_impl<dd::Table>
----------row_merge_build_indexes
```

#1.2 row_merge_build_indexes

```cpp
row_merge_build_indexes
--trx_start_if_not_started_xa
--trx_set_flush_observer
--row_merge_create_fts_sort_index//word, Doc ID, and word's position
--row_fts_psort_info_init
----row_merge_buf_create
------row_merge_buf_create_low
----row_merge_file_create
------row_merge_file_create_low
--innobase_rec_reset
----Field::set_default

--row_merge_read_clustered_index
----fts_sync_table
------fts_sync
--------fts_sync_index
----------fts_sync_write_words
------------fts_write_node
--------------fts_eval_sql
----------------que_run_threads
------------------que_run_threads_low
--------------------que_thr_step
----------------------row_ins_step
------------------------row_ins
--------------------------row_ins_index_entry_step
----------------------------row_ins_index_entry
------------------------------row_ins_clust_index_entry
--------------------------------row_ins_clust_index_entry_low
----------------------------------btr_cur_optimistic_insert
------------------------------------page_cur_tuple_insert
--------------------------------------page_cur_insert_rec_low
```