#1.buf_flush_page_coordinator_thread

```cpp
buf_flush_page_coordinator_thread
--buf_flush_lists
----buf_flush_do_batch
------buf_flush_start
--------buf_pool->init_flush[flush_type] = TRUE;
--------os_event_reset(buf_pool->no_flush[flush_type]);
------buf_flush_batch
--------buf_do_flush_list_batch
----------prev = UT_LIST_GET_PREV(list, bpage);
----------buf_pool->flush_hp.set(prev);
----------buf_flush_page_and_try_neighbors
------------buf_flush_ready_for_flush
------------buf_flush_try_neighbors
--------------//offset = 3506176
--------------//fil_space_get_size(space)
------buf_flush_end
--------buf_pool->init_flush[flush_type] = FALSE;
--------buf_pool->try_LRU_scan = TRUE;
--------os_event_set(buf_pool->no_flush[flush_type]);
--------buf_dblwr_flush_buffered_writes
```