#1.buf_flush_do_batch

```cpp
/** Do flushing batch of a given type.
NOTE: The calling thread is not allowed to own any latches on pages!
@param[in,out]  buf_pool    buffer pool instance
@param[in]  type        flush type
@param[in]  min_n       wished minimum mumber of blocks flushed
(it is not guaranteed that the actual number is that big, though)
@param[in]  lsn_limit   in the case BUF_FLUSH_LIST all blocks whose
oldest_modification is smaller than this should be flushed (if their number
does not exceed min_n), otherwise ignored
@param[out] n_processed the number of pages which were processed is
passed back to caller. Ignored if NULL
@retval true    if a batch was queued successfully.
@retval false   if another batch of same type was already running. */

buf_flush_do_batch
--buf_flush_start
----buf_pool->init_flush[flush_type] = TRUE;
----os_event_reset(buf_pool->no_flush[flush_type]);
--buf_flush_batch
----buf_do_flush_list_batch//FLUSH_LIST
-------buf_flush_page_and_try_neighbors
----buf_do_LRU_batch//FLUSH_LRU
--buf_flush_end
----buf_pool->init_flush[flush_type] = FALSE;
----buf_pool->try_LRU_scan = TRUE;
----os_event_set(buf_pool->no_flush[flush_type]);
----buf_dblwr_flush_buffered_writes
```

#2.caller

##2.1 buf_pool_withdraw_blocks

```cpp
buf_resize_thread
--buf_pool_resize
----buf_pool_withdraw_blocks
------buf_flush_do_batch(buf_pool, BUF_FLUSH_LRU, scan_depth, 0, &n_flushed);
------buf_flush_wait_batch_end(buf_pool, BUF_FLUSH_LRU);
```

##2.2 buf_flush_lists

```cpp
buf_flush_do_batch(buf_pool, BUF_FLUSH_LIST, min_n, lsn_limit,&page_count)
```

##2.3 buf_flush_LRU_list 

```cpp
buf_flush_do_batch(buf_pool, BUF_FLUSH_LRU, scan_depth, 0, &n_flushed);
```

##2.4 pc_flush_slot

```cpp
buf_flush_do_batch(buf_pool, BUF_FLUSH_LIST, slot->n_pages_requested,page_cleaner->lsn_limit, &slot->n_flushed_list);
```