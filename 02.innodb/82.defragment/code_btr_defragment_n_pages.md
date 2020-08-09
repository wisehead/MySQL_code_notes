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

