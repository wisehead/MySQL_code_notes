#1. btr_page_get_father_block

```cpp
btr_page_get_father_block
--page_get_infimum_rec
--page_rec_get_next
--btr_cur_position
----page_cur_position
--btr_page_get_father_node_ptr/btr_page_get_father_node_ptr_func
----dict_index_build_node_ptr
------dtuple_create
------dict_index_copy_types
------dtype_set
------rec_copy_prefix_to_dtuple
--------dtuple_set_info_bits
--------dfield_set_data
------dtuple_set_info_bits(tuple, dtuple_get_info_bits(tuple)| REC_STATUS_NODE_PTR);
----btr_cur_search_to_nth_level
----btr_node_ptr_get_child_page_no
------page_no = mach_read_from_4(field)
```