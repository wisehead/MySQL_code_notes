#1.btr_pcur_move_to_next

```cpp
caller:
--row_search_for_mysql

btr_pcur_move_to_next
--btr_pcur_is_after_last_on_page
----page_cur_is_after_last
------page_rec_is_supremum
--------page_rec_is_supremum_low
--btr_pcur_move_to_next_on_page
----page_cur_move_to_next
------page_rec_get_next
--------page_rec_get_next_low
----------rec_get_next_offs
```

#2.btr_pcur_store_position

```cpp
caller:
--row_search_for_mysql

btr_pcur_store_position
--btr_pcur_get_block
----btr_pcur_get_btr_cur
----btr_cur_get_block
------btr_cur_get_page_cur
------page_cur_get_block
--btr_pcur_get_btr_cur
--btr_cur_get_index
--btr_pcur_get_page_cur
----btr_pcur_get_btr_cur
----btr_cur_get_page_cur
--page_cur_get_rec
--page_is_empty
--dict_index_copy_rec_order_prefix
----dict_index_get_n_unique_in_tree
------dict_index_get_n_unique
----rec_copy_prefix_to_buf
```

#3. btr_pcur_open_low

```cpp
caller:
--btr_pcur_open_on_user_rec_func
--dict_create_index_tree_step

btr_pcur_open_low
--btr_pcur_init
--btr_pcur_get_btr_cur
--btr_cur_search_to_nth_level
```

#4.btr_cur_search_to_nth_level

```cpp
btr_cur_search_to_nth_level
--btr_cur_get_and_clear_intention
--mtr_set_savepoint
--btr_cur_latch_for_root_leaf
--buf_page_get_gen
--btr_page_get_level_low
--page_cur_search_with_match
----page_check_dir
----page_dir_slot_get_rec
----ut_pair_min
----rec_get_offsets_func
------rec_get_n_fields_old
------rec_init_offsets
----cmp_dtuple_rec_with_match_low
------dtuple_get_nth_field
------rec_get_nth_field_offs
--------rec_byte = cmp_collate(rec_byte);
--------dtuple_byte = cmp_collate(dtuple_byte);
----page_rec_get_next_const
------page_rec_get_next_low
--------rec_get_next_offs
----------field_value = mach_read_from_2(rec - REC_NEXT);
```













