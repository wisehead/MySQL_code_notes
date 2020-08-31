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
--------buf_LRU_block_remove_hashed//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
----------buf_LRU_remove_block
------------UT_LIST_REMOVE(LRU, buf_pool->LRU, bpage);
------------buf_unzip_LRU_remove_block_if_needed
--------------buf_page_belongs_to_unzip_LRU
--------------UT_LIST_REMOVE(unzip_LRU, buf_pool->unzip_LRU, block);
----------buf_page_hash_get_low
----------HASH_DELETE(buf_page_t, hash, buf_pool->page_hash, fold, bpage);
----------//case BUF_BLOCK_ZIP_PAGE:
----------buf_buddy_free
------------buf_buddy_free_low
----------buf_page_free_descriptor
------------ut_free
--------buf_LRU_add_block_low
--------buf_flush_relocate_on_flush_list
--------buf_pagev_set_sticky
--------btr_search_drop_page_hash_index
--------buf_page_unset_sticky
--------buf_LRU_block_free_hashed_page
----------buf_LRU_block_free_non_file_page
--buf_flush_single_page_from_LRU
----buf_flush_page
------buf_flush_write_block_low
--------log_write_up_to
--------buf_flush_init_for_writing
--------fil_io
--------if (sync) fil_flush
----buf_LRU_free_page

```