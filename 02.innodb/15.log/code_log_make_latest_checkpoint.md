#1. log_make_latest_checkpoint

```cpp
log_make_latest_checkpoint()
--log_make_latest_checkpoint(log_t &log)
----log_get_lsn
------log_translate_sn_to_lsn
--------return (sn / LOG_BLOCK_DATA_SIZE * OS_FILE_LOG_BLOCK_SIZE +sn % LOG_BLOCK_DATA_SIZE + LOG_BLOCK_HDR_SIZE);
----log_preflush_pool_modified_pages
------log_buffer_flush_order_lag
--------log.recent_closed.capacity()
------new_oldest += log_buffer_flush_order_lag(log)
------buf_flush_request_force
--------lsn_target = lsn_limit + lsn_avg_rate * 3
--------buf_flush_sync_lsn = lsn_target
--------os_event_set(buf_flush_event);//buf_flush_page_coordinator_thread,开始干活。
------buf_flush_wait_flushed
--------bpage = UT_LIST_GET_LAST(buf_pool->flush_list);
--------if (oldest == 0 || oldest >= new_oldest) { break; }
```

