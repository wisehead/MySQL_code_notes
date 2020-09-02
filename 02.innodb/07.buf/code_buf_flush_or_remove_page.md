#1. buf_flush_or_remove_page

```cpp
/** Removes a single page from a given tablespace inside a specific
buffer pool instance.
@param[in,out]  buf_pool    buffer pool instance
@param[in,out]  bpage       bpage to remove
@param[in]  flush       flush to disk if true but don't remove
                                else remove without flushing to disk
@param[in,out]  must_restart    flag if must restart the flush list scan
@return true if page was removed. */

buf_flush_or_remove_page
--// else if (!flush)
----buf_flush_remove(bpage)
------//case BUF_BLOCK_ZIP_DIRTY:
--------buf_page_set_state(bpage, BUF_BLOCK_ZIP_PAGE);
--------UT_LIST_REMOVE(buf_pool->flush_list, bpage);
------//case BUF_BLOCK_FILE_PAGE:
--------UT_LIST_REMOVE(buf_pool->flush_list, bpage);
------buf_flush_delete_from_flush_rbt(bpage);
--//else if (buf_flush_ready_for_flush(bpage, BUF_FLUSH_SINGLE_PAGE))
----buf_flush_page(buf_pool, bpage, BUF_FLUSH_SINGLE_PAGE, false);
----os_aio_simulated_wake_handler_threads


```

#2.caller

```cpp
buf_LRU_flush_or_remove_pages
--buf_LRU_remove_pages
----buf_flush_dirty_pages
------buf_flush_or_remove_pages
--------buf_flush_or_remove_page
```