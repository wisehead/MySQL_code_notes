#1. page_copy_rec_list_end

```cpp
page_copy_rec_list_end
--page_copy_rec_list_end_to_created_page
----page_copy_rec_list_to_created_page_write_log
------mlog_open_and_write_index
--------mlog_open
----rec_get_offsets
----rec_copy
----rec_set_next_offs_new//更新rec的NEXT_REC field
------mach_write_to_2(rec - REC_NEXT, field_value);
----rec_set_n_owned_new
----rec_set_heap_no_new
----rec_offs_size
----page_cur_insert_rec_write_log
------mlog_open_and_write_index
----page_rec_get_next
------page_rec_get_next_low
--------rec_get_next_offs
----------mach_read_from_2(rec - REC_NEXT)
----rec_set_next_offs_new
--lock_move_rec_list_end
--btr_search_move_or_delete_hash_entries
----btr_search_drop_page_hash_index
------ha_remove_all_nodes_to_page
--------ha_chain_get_first(table, fold);
--------ha_delete_hash_node
----------HASH_DELETE_AND_COMPACT(ha_node_t, next, table, del_node);
--------ha_chain_get_next(node);
```