#1.buf_flush_LRU_list_batch

```cpp
/** This utility flushes dirty blocks from the end of the LRU list.
The calling thread is not allowed to own any latches on pages!
It attempts to make 'max' blocks available in the free list. Note that
it is a best effort attempt and it is not guaranteed that after a call
to this function there will be 'max' blocks in the free list.
@param[in]  buf_pool    buffer pool instance
@param[in]  max     desired number for blocks in the free_list
@return number of blocks for which the write request was queued. */

buf_flush_LRU_list_batch
--buf_get_withdraw_depth
--buf_flush_ready_for_replace
----buf_page_in_file
----return (bpage->oldest_modification == 0 && bpage->buf_fix_count == 0 &&buf_page_get_io_fix(bpage) == BUF_IO_NONE);
--buf_LRU_free_page
--buf_flush_ready_for_flush
--buf_flush_page_and_try_neighbors
```

#2.caller

```cpp
buf_flush_do_batch
--buf_flush_batch
----buf_do_LRU_batch
------buf_flush_LRU_list_batch
```