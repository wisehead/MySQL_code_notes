#1.page_cur_search_with_match

```cpp
//在page内找一个rec
//先二分查找slot，然后slot内顺序查找。
caller:
--btr_cur_search_to_nth_level

page_cur_search_with_match
--rec_get_offsets_func
----dict_index_get_n_unique_in_tree
----rec_offs_set_n_fields
----rec_init_offsets
--cmp_dtuple_rec_with_match_low
----dtuple_get_nth_field
--page_cur_position
```