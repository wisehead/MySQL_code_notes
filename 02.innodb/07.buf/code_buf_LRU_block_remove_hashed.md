#1. buf_LRU_block_remove_hashed

```cpp
buf_LRU_block_remove_hashed
--buf_page_hash_lock_get
--buf_LRU_remove_block
----buf_LRU_adjust_hp
----UT_LIST_REMOVE(buf_pool->LRU, bpage);
----buf_unzip_LRU_remove_block_if_needed
------buf_page_belongs_to_unzip_LRU
--------return (bpage->zip.data && buf_page_get_state(bpage) == BUF_BLOCK_FILE_PAGE);
------UT_LIST_REMOVE(buf_pool->unzip_LRU, block);
--buf_page_hash_get_low
--HASH_DELETE(buf_page_t, hash, buf_pool->page_hash, fold, bpage);
--//case BUF_BLOCK_FILE_PAGE:
--memset(((buf_block_t *)bpage)->frame + FIL_PAGE_OFFSET, 0xff, 4);
--memset(((buf_block_t *)bpage)->frame + FIL_PAGE_ARCH_LOG_NO_OR_SPACE_ID,0xff, 4);
--buf_page_set_state(bpage, BUF_BLOCK_REMOVE_HASH);
```