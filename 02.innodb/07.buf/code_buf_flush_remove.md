#1.buf_flush_remove

```cpp
caller:
--buf_flush_write_complete
--buf_flush_or_remove_page
--buf_LRU_remove_all_pages


buf_flush_remove
```

#2. buf_flush_write_complete

```cpp
caller:
--buf_page_io_complete
```

#3.buf_page_io_complete

```cpp
caller:
--buf_flush_write_block_low
--buf_read_page_low
--fil_aio_wait
```