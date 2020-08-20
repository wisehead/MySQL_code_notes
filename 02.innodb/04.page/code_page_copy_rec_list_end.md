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

```