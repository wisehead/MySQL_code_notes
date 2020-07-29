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
----------row_merge_buf_encode
------------rec_convert_dtuple_to_temp
--------------rec_convert_dtuple_to_rec_comp
--btr_pcur_open_at_index_side//btr_pcur_t::open_at_side
----btr_cur_open_at_index_side_func
------mtr_s_lock(dict_index_get_lock(index), mtr);
--page_cur_move_to_next
--page_cur_get_rec
--rec_get_offsets_func
----rec_init_offsets
------rec_init_offsets_comp_ordinary
--row_build_w_add_vcol
----row_build_low
------dtuple_create_with_vcol
------dict_table_copy_types
--------dict_table_copy_v_types//virtual columns
--dtuple_set_info_bits
--row_merge_buf_add
--btr_page_get_next
--row_merge_buf_free
--row_fts_free_pll_merge_buf
--btr_pcur_close
--fts_sync_table

```