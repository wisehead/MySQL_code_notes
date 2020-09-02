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
----memset(((buf_block_t *)bpage)->frame + FIL_PAGE_OFFSET, 0xff, 4);
----memset(((buf_block_t *)bpage)->frame + FIL_PAGE_ARCH_LOG_NO_OR_SPACE_ID,0xff, 4);
----buf_page_set_state(bpage, BUF_BLOCK_REMOVE_HASH);
----//if (zip && bpage->zip.data)
------bpage->zip.data = NULL;
------buf_buddy_free
------page_zip_set_size
----//end if
--//case end
--//case BUF_BLOCK_ZIP_PAGE:
----buf_buddy_free
------buf_buddy_get_slot
------buf_buddy_free_low
--------os_atomic_decrement_ulint(&buf_pool->buddy_stat[i].used, 1);
----buf_page_free_descriptor
------ut_free(bpage);
--//case end
```