#1.btr_ibd_reclaim_thread

```cpp
btr_ibd_reclaim_thread
--btr_reclaim_add_defragment_item
----btr_gen_defragment_item_for_db
------dtuple_create
------dfield_set_data
------dict_index_copy_types
------btr_pcur_open_on_user_rec_func
--------btr_pcur_open_low
----------btr_pcur_init
----------btr_cur_search_to_nth_level

```