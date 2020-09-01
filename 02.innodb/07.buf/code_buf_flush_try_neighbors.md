#1.buf_flush_try_neighbors

```cpp
buf_flush_try_neighbors
--buf_flush_area = std::min(BUF_READ_AHEAD_AREA(buf_pool),static_cast<page_no_t>(buf_pool->curr_size / 16));
--low = (page_id.page_no() / buf_flush_area) * buf_flush_area;
--high = (page_id.page_no() / buf_flush_area + 1) * buf_flush_area;
--buf_flush_check_neighbor
----buf_page_hash_get_s_locked
------buf_page_hash_get_locked
--------hash_get_lock
----------hash_get_sync_obj_index
------------hash_calc_hash
------------ut_2pow_remainder(hash_calc_hash(fold, table), table->n_sync_obj)
----------hash_get_nth_lock
```

#2.caller 

```cpp
buf_flush_page_and_try_neighbors
--buf_flush_ready_for_flush
--buf_flush_try_neighbors
```
