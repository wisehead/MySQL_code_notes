#1. page_create

```cpp
page_create
--page_create_write_log
----mlog_write_initial_log_record(MLOG_COMP_PAGE_CREATE)
--page_create_low
----fil_page_set_type(page, FIL_PAGE_INDEX);
```

#2. page_create_low

```cpp
page_create_low
--fil_page_set_type(page, FIL_PAGE_INDEX);
--rec_convert_dtuple_to_rec
----rec_convert_dtuple_to_rec_new
------dtuple_get_info_bits
------rec_get_converted_size_comp
------rec_convert_dtuple_to_rec_comp
------rec_set_info_and_status_bits
--------rec_set_status
----------rec_set_bit_field_1
--------rec_set_info_bits_new
--rec_set_n_owned_new
--rec_set_heap_no_new
--rec_get_offsets_func
----rec_offs_set_n_alloc
----rec_offs_set_n_fields
----rec_init_offsets
```