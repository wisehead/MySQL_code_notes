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
--buf_flush_write_block_low//true
--buf_read_page_low//false
--fil_aio_wait//false
```

#4. buf_flush_write_block_low

```cpp
caller:
--buf_flush_page
```


#5. buf_flush_page
```cpp
caller:
--buf_flush_page_try//for debug, BUF_FLUSH_SINGLE_PAGE, true
--buf_flush_try_neighbors//flush_type, false
--buf_flush_single_page_from_LRU//BUF_FLUSH_SINGLE_PAGE, true
--buf_flush_or_remove_page//BUF_FLUSH_SINGLE_PAGE, false
```

#6. buf_flush_or_remove_page

```cpp
caller:
--buf_flush_or_remove_pages
```

#7.buf_flush_or_remove_pages

```cpp
caller:
--buf_flush_dirty_pages
```

#8. buf_flush_dirty_pages

```cpp
caller:
buf_LRU_flush_or_remove_pages
--buf_LRU_remove_pages
```

#9. buf_LRU_flush_or_remove_pages

```cpp
caller:
--fil_close_tablespace
--fil_delete_tablespace
--row_import_for_mysql
--row_quiesce_table_start
```