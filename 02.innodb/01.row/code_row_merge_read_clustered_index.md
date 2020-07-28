#1. row_merge_read_clustered_index

```cpp
caller:
--row_merge_build_indexes


row_merge_read_clustered_index
--fts_sync_table
----fts_sync
------fts_sync_index
--------fts_sync_write_words
----------fts_write_node
------------fts_eval_sql
--------------que_run_threads
----------------que_run_threads_low
------------------que_thr_step
--------------------row_ins_step
----------------------row_ins
------------------------row_ins_index_entry_step
--------------------------row_ins_index_entry
----------------------------row_ins_clust_index_entry
------------------------------row_ins_clust_index_entry_low
--------------------------------btr_cur_optimistic_insert
----------------------------------page_cur_tuple_insert
------------------------------------page_cur_insert_rec_low

```