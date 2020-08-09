#1. btr_cur_search_to_nth_level

```cpp
btr_cur_search_to_nth_level
--mtr_set_savepoint
--mtr_s_lock(dict_index_get_lock(index), mtr);//lock index->lock
--btr_cur_latch_for_root_leaf
--dict_index_get_space(index)
--dict_index_get_page(index)
--tree_savepoints[n_blocks] = mtr_set_savepoint(mtr)
--buf_page_get_gen//index root
--page_cur_search_with_match
----rec_get_offsets_func
------dict_index_get_n_unique_in_tree
------rec_offs_set_n_fields
------rec_init_offsets
----cmp_dtuple_rec_with_match_low
```