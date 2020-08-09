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

#3. page_cur_insert_rec_low

```cpp
page_cur_insert_rec_low
--free_rec = page_header_get_ptr(page, PAGE_FREE);
--page_mem_alloc_heap
----page_get_max_insert_size//假设没有空洞。
----page_header_set_ptr(page, page_zip, PAGE_HEAP_TOP,block + need);
----page_dir_set_n_heap
--/* 3. Create the record */
--rec_copy
--/* 4. Insert the record in the linked list of records */
--page_rec_set_next(insert_rec, next_rec)
--page_rec_set_next(current_rec, insert_rec)
--page_header_set_field(page, NULL, PAGE_N_RECS,1 + page_get_n_recs(page));
--/* 5. Set the n_owned field in the inserted record to zero,and set the heap_no field */
--rec_set_n_owned_new(insert_rec, NULL, 0);
--rec_set_heap_no_new(insert_rec, heap_no);
--/* 6. Update the last insertion info in page header */
--set PAGE_DIRECTION
--set PAGE_N_DIRECTION
--page_header_set_ptr(page, NULL, PAGE_LAST_INSERT, insert_rec);
--/* 7. It remains to update the owner record. */
--rec_set_n_owned_new(owner_rec, NULL, n_owned + 1);
--page_cur_insert_rec_write_log
```