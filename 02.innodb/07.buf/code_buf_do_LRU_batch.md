#1.buf\_do\_LRU_batch

```cpp
/** Flush and move pages from LRU or unzip_LRU list to the free list.
Whether LRU or unzip_LRU is used depends on the state of the system.
@param[in]  buf_pool    buffer pool instance
@param[in]  max     desired number of blocks in the free_list
@return number of blocks for which either the write request was queued
or in case of unzip_LRU the number of blocks actually moved to the
free list */

buf_do_LRU_batch
--buf_LRU_evict_from_unzip_LRU
----return (unzip_avg <= io_avg * BUF_LRU_IO_TO_UNZIP_FACTOR);
--buf_free_from_unzip_LRU_list_batch
----buf_LRU_free_page
--buf_flush_LRU_list_batch
```

#2.caller

```cpp
buf_flush_lists/buf_flush_LRU_list/pc_flush_slot
--buf_flush_do_batch
----buf_flush_batch
------buf_do_LRU_batch
```

