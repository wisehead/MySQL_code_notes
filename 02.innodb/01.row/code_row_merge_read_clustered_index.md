#1. row_merge_read_clustered_index

```cpp
caller:
--row_merge_build_indexes


row_merge_read_clustered_index
--row_merge_buf_create
----row_merge_buf_create_low
--row_fts_start_psort
----os_thread_create(fts_parallel_tokenization_thread)
------fts_parallel_tokenization_thread
--------row_merge_fts_get_next_doc_item
--------row_merge_fts_doc_tokenize
----------row_merge_fts_doc_tokenize_by_parser
------------ngram_parser_parse
--------------ngram_parse
----------------row_merge_fts_doc_add_word_for_parser
----------fts_check_token
----------innobase_fts_casedn_str
----------fts_check_token
----------fts_select_index
--------row_merge_buf_sort
----------row_merge_tuple_sort
------------UT_SORT_FUNCTION_BODY
--------row_merge_buf_write
----------

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