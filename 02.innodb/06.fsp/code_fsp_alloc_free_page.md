#1.fsp_alloc_free_page

```cpp
fsp_alloc_free_page
--xdes_get_descriptor_with_space_hdr
--xdes_find_bit
--xdes_get_offset
--fsp_alloc_from_free_frag
----xdes_set_bit
----frag_n_used = mtr_read_ulint(header + FSP_FRAG_N_USED, ..)
----frag_n_used++;
----xdes_is_full
--fsp_page_create
----buf_page_create
----buf_block_buf_fix_inc_func
----mtr_memo_push
----fsp_init_file_page
------fsp_init_file_page_low
------mlog_write_initial_log_record(MLOG_INIT_FILE_PAGE)
```