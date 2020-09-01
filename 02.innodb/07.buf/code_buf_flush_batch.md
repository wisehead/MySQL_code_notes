#1.buf_flush_batch

```cpp
/** This utility flushes dirty blocks from the end of the LRU list or
flush_list.
NOTE 1: in the case of an LRU flush the calling thread may own latches to
pages: to avoid deadlocks, this function must be written so that it cannot
end up waiting for these latches! NOTE 2: in the case of a flush list flush,
the calling thread is not allowed to own any latches on pages!
@param[in]  buf_pool    buffer pool instance
@param[in]  flush_type  BUF_FLUSH_LRU or BUF_FLUSH_LIST; if
BUF_FLUSH_LIST, then the caller must not own any latches on pages
@param[in]  min_n       wished minimum mumber of blocks flushed (it is
not guaranteed that the actual number is that big, though)
@param[in]  lsn_limit   in the case of BUF_FLUSH_LIST all blocks whose
oldest_modification is smaller than this should be flushed (if their number
does not exceed min_n), otherwise ignored
@return number of blocks for which the write request was queued */

buf_flush_batch
--//case BUF_FLUSH_LRU:
--buf_do_LRU_batch(buf_pool, min_n);
--//BUF_FLUSH_LIST
--buf_do_flush_list_batch(buf_pool, min_n, lsn_limit);
```

#2.caller buf_flush_do_batch