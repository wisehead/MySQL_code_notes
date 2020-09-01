#1.buf_flush_try_neighbors
以FLUSH_LIST为主，也可以少量FLUSH_LRU

```cpp
buf_flush_try_neighbors
--buf_flush_area = std::min(BUF_READ_AHEAD_AREA(buf_pool),static_cast<page_no_t>(buf_pool->curr_size / 16));
--low = (page_id.page_no() / buf_flush_area) * buf_flush_area;
--high = (page_id.page_no() / buf_flush_area + 1) * buf_flush_area;
--buf_flush_check_neighbor
----buf_page_hash_get_s_locked
----block_mutex = buf_page_get_mutex(bpage);
----mutex_enter(block_mutex);
----rw_lock_s_unlock(hash_lock);
----buf_flush_ready_for_flush
----mutex_exit(block_mutex);
--//for (i = low; i < high; i++)
--//if (flush_type != BUF_FLUSH_LRU || i == page_id.page_no() ||buf_page_is_old(bpage)) {
--//if (buf_flush_ready_for_flush(bpage, flush_type) && (i == page_id.page_no() || bpage->buf_fix_count == 0)) {
--buf_flush_page(buf_pool, bpage, flush_type, false)
--//end for
```

#2.caller 

```cpp
buf_flush_page_and_try_neighbors
--buf_flush_ready_for_flush
--buf_flush_try_neighbors
```
