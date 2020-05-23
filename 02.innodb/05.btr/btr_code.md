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
--
```