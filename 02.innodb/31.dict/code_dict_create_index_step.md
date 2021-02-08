#1. dict_create_index_step

```cpp
dict_create_index_step
--dict_build_index_def_step
----dict_hdr_get_new_id//for index
----dict_create_sys_indexes_tuple
----ins_node_set_new_row
```

#2.dict_build_field_def_step

```cpp
dict_build_field_def_step
--dict_create_sys_fields_tuple
--ins_node_set_new_row
```

#3.dict_create_index_tree_step

```cpp
dict_create_index_tree_step
--dict_create_search_tuple
--btr_pcur_open_low
--btr_pcur_move_to_next_user_rec
----btr_pcur_move_to_next_on_page
------page_cur_move_to_next
--------page_rec_get_next
----------page_rec_is_comp
----------page_rec_get_next_low
------------rec_get_next_offs
--btr_create
--btr_pcur_close
```
