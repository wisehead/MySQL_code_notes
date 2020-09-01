#1.buf_flush_lists

```cpp
/** This utility flushes dirty blocks from the end of the flush list of all
buffer pool instances.
NOTE: The calling thread is not allowed to own any latches on pages!
@param[in]  min_n       wished minimum mumber of blocks flushed
                                (it is not guaranteed that the actual number
                                is that big, though)
@param[in]  lsn_limit   in the case BUF_FLUSH_LIST all blocks whose
                                oldest_modification is smaller than this
                                should be flushed (if their number does not
                                exceed min_n), otherwise ignored
@param[out] n_processed the number of pages which were processed is
                                passed back to caller. Ignored if NULL.

@return true if a batch was queued successfully for each buffer pool
instance. false if another batch of same type was already running in
at least one of the buffer pool instance */

buf_flush_lists
--min_n = (min_n + srv_buf_pool_instances - 1) / srv_buf_pool_instances;
--for (ulint i = 0; i < srv_buf_pool_instances; i++)
--buf_flush_do_batch(buf_pool, BUF_FLUSH_LIST, min_n, lsn_limit,&page_count)
--//end for
```

#2.caller

##2.1 buf_flush_page_coordinator_thread

```cpp
buf_flush_lists(PCT_IO(srv_idle_flush_pct), LSN_MAX, &n_flushed);
```

##2.2 buf_flush_sync_all_buf_pools

```cpp
success = buf_flush_lists(ULINT_MAX, LSN_MAX, &n_pages);
```