#1.buf\_flush\_page

```cpp
buf_flush_page
--os_event_reset(buf_pool->no_flush[flush_type]);
--++buf_pool->n_flush[flush_type]
--buf_dblwr_flush_buffered_writes//if (!fsp_is_system_temporary(bpage->id.space()))
--buf_dblwr_sync_datafiles//if system temporary
--buf_flush_write_block_low//!!!!!!!!!!!!
----log_write_up_to
----if ZIP_PAGE, update LSN, checksum
----if FILE_PAGE, buf_flush_init_for_writing
----fil_io//这里可以写压缩页，也可以写非压缩页。这取决于上层控制。如果是压缩表，需要压缩一下，再写入磁盘吗？？？？
----fil_flush//if sync
----buf_page_io_complete//if sync
```

#2.callers

```cpp
--buf_flush_try_neighbors
--buf_flush_single_page_from_LRU
--buf_flush_or_remove_page
```