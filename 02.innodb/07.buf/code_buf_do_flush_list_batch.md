#1.buf_do_flush_list_batch

```cpp
/** This utility flushes dirty blocks from the end of the flush_list.
The calling thread is not allowed to own any latches on pages!
@param[in]  buf_pool    buffer pool instance
@param[in]  min_n       wished minimum mumber of blocks flushed (it is
not guaranteed that the actual number is that big, though)
@param[in]  lsn_limit   all blocks whose oldest_modification is smaller
than this should be flushed (if their number does not exceed min_n)
@return number of blocks for which the write request was queued;
ULINT_UNDEFINED if there was a flush of the same type already
running */

buf_do_flush_list_batch
--for (buf_page_t *bpage = UT_LIST_GET_LAST(buf_pool->flush_list);
       count < min_n && bpage != NULL && len > 0 &&
       bpage->oldest_modification < lsn_limit;
       bpage = buf_pool->flush_hp.get(), ++scanned)
--buf_flush_page_and_try_neighbors(bpage, BUF_FLUSH_LIST, min_n, &count);
--end for
```

#2.caller buf_flush_batch