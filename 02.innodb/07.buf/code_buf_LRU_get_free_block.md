#1.buf_LRU_get_free_block

```cpp
buf_LRU_get_free_block
--buf_LRU_get_free_only
--buf_LRU_scan_and_free_block//从LRU中move一部分block到free list
----buf_LRU_free_from_unzip_LRU_list
------buf_LRU_evict_from_unzip_LRU
------buf_LRU_free_page
----buf_LRU_free_from_common_LRU_list
------buf_LRU_free_page
--buf_flush_single_page_from_LRU
----buf_flush_page
------buf_flush_write_block_low
--------log_write_up_to
--------buf_flush_init_for_writing
--------fil_io
--------if (sync) fil_flush
----buf_LRU_free_page

```