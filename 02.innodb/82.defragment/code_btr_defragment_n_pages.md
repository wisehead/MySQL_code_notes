#1. btr_defragment_n_pages

```cpp
btr_defragment_n_pages
--/* 1. Load the pages and calculate the total data size. */
--blocks[i] = btr_block_get//get 64 pages
--/* 2. Calculate how many pages data can fit in. If not compressable,return early. */
--/* 3. Defragment pages. */
--btr_defragment_merge_pages
----page_get_n_recs(from_page)
----page_get_data_size(to_page)
----page_get_max_insert_size
----page_get_max_insert_size_after_reorganize
------page_get_data_size + page_dir_calc_reserved_space
------page_get_free_space_of_empty
----btr_defragment_calc_n_recs_for_size
----page_rec_get_nth
----page_copy_rec_list_start
------
```

#2.page_copy_rec_list_start

```cpp
page_copy_rec_list_start
--page_cur_set_before_first
----page_get_infimum_rec
--page_cur_move_to_next
----page_rec_get_next
------page_rec_get_next_low
--------offs = rec_get_next_offs(rec, comp)
--------return page + offs
--rec_get_offsets_func
----dict_index_get_n_fields
----rec_offs_set_n_fields
----rec_init_offsets
--page_cur_insert_rec_low
--page_cur_move_to_next
```

