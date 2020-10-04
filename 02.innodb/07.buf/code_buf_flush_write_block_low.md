#1.buf_flush_write_block_low

```cpp
// 将 LRU list / flush list 上的一个脏页持久化
buf_flush_write_block_low
  // 设置 IO 状态为 BUF_IO_WRITE
  |- buf_page_set_io_fix
  // 将 Buffer Pool 中的一个脏页持久化（写回磁盘）
  |- buf_flush_write_block_low
    // WAL的保证：确定在 page->newest_modification 之前的日志都已经持久化
    |- log_write_up_to
    // 这里要分三种情况：
    // 第1种 - 关闭 double write / 只读模式（srv_read_only_mode） / 临时表。
    //        均以异步IO模式写回磁盘，不经过 double write
    |- fil_io
    // 第2种 - 在 LRU list 尾部刷脏一个数据页（flush_type 是 BUF_FLUSH_SINGLE_PAGE）
    // 在 buf_LRU_get_free_block 里可能存在这种情况，见上文
    |- buf_dblwr_write_single_page
    // 第3种 - 其他情况（一般的 page cleaner 刷脏页），将脏页加入到 double write buffer 中
    // 而不急于写到系统表空间的 double write 区域
    |- buf_dblwr_add_to_batch
      // 3-1. 当 double write buffer 写满后，将其中的内容 *同步的*（sync=true）写到系统表空间 double write 区域
      // 并调用 fsync
      |- buf_dblwr_flush_buffered_writes
        |- fil_io & fil_flush(TRX_SYS_SPACE)
        // 将对应的数据页*异步的*（sync=false, InnoDB simulated AIO）写回到用户表空间中
        // 并当数据页落盘后，在 buf_page_io_complete 中将数据页其从 flush list 上移除
        |- buf_dblwr_write_block_to_datafile
      // 3-2. 当 double write buffer 还有空余，将数据页直接拷贝到 double write buffer 中
      |- memcpy (buf_dblwr->write_buf ...)
      
```