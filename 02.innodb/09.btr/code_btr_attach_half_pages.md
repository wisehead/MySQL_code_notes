#1.btr_attach_half_pages

```cpp
caller:
--btr_page_split_and_insert
--btr_reclaim_n_pages

btr_attach_half_pages
--btr_page_get_father_block
--btr_node_ptr_set_child_page_no
--node_ptr_upper = dict_index_build_node_ptr(index, split_rec,upper_page_no, heap, level);
--btr_insert_on_non_leaf_level_func
----btr_cur_search_to_nth_level
----btr_cur_optimistic_insert
```