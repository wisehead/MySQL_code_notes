#1.buf_flush_single_page_from_LRU

```cpp
buf_flush_single_page_from_LRU
--bpage = buf_pool->single_scan_itr.start()
--if (buf_flush_ready_for_replace)
----buf_LRU_free_page(bpage, true)
--if (buf_flush_ready_for_flush(bpage, BUF_FLUSH_SINGLE_PAGE))
----buf_flush_page(buf_pool, bpage, BUF_FLUSH_SINGLE_PAGE, true)
```

#2.caller

```cpp
buf_LRU_get_free_block
--buf_flush_single_page_from_LRU
```