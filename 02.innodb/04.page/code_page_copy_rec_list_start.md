#1. page_copy_rec_list_start

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
--page_zip_compress
--page_zip_reorganize
```