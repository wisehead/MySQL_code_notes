#1. page_cur_delete_rec_write_log

```cpp
page_cur_delete_rec_write_log
--mlog_open_and_write_index
----mlog_open
----mlog_write_initial_log_record_fast
------mach_write_to_1(log_ptr, type);//mlog_type
------mach_write_compressed(log_ptr, space)
------mach_write_compressed(log_ptr, offset);
----mach_write_to_2(log_ptr, n);//n = dict_index_get_n_fields(index)
----mach_write_to_2(log_ptr,dict_index_get_n_unique_in_tree(index));
----//for (i = 0; i < n; i++)
----mach_write_to_2(log_ptr, len);
----//end for
--mach_write_to_2(log_ptr, page_offset(rec));
--mlog_close(mtr, log_ptr + 2);
```