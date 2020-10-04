#1.buf_page_get_gen

```cpp
// 从 Buffer Pool 或磁盘上获得一个 Page。Page fetch mode：
//   1-NORMAL：若不在 BP 中则从磁盘文件载入到 BP 中
//   2-SCAN：同 NORMAL，但是暗示这是一次大规模的扫描（e.g Table Scan）
//   3-IF_IN_POOL：只在 BP 中查找没，如果不在则返回
//   4-PEEK_IF_IN_POOL：同 IF_IN_POOL，但不要将数据页放在 LRU list young 区域
//   5-IF_IN_POOL_OR_WATCH：同 IF_IN_POOL，但如果不在则设置数据页为 "watch"（与 purge 线程有关）
//   NO_LATCH/POSSIBLY_FREED... 暂不明确
Buf_fetch<T>::single_page
  // Step-1：在 BP 中查找指定的数据页，若不存在则从磁盘文件中载入到BP
  |- Buf_fetch_normal::get
    // Step-1.1：在 page_hash 里查找该数据页，需要持有 bucket lock
    |- lookup
      |- buf_page_hash_get_low
        |- HASH_SEARCH...
 
    // Step-1.2：从磁盘读数据页到 Buffer Pool
    |- read_page
      // Step-1.2.1：在 Buffer Pool 中初始化一个结构体 buf_block_t/buf_page_t 来代表即将被读上来的数据页
      // 如果发生下述三种情况，函数直接返回：
      //   1- 结构体 buf_block_t/buf_page_t 已经在 Buffer Pool 中（数据页正在被读上来，或已经在 Buffer Pool
      //      中. 表示可能被其他的 reader "抢先"）
      //   2- 表空间在被删除过程中
      //   3- 模式是 BUF_READ_IBUF_PAGES_ONLY（只读 ibuf 数据页），但 page_id 并不属于 ibuf B-tree
      //     （ibuf_page_low）
      |- buf_page_init_for_read
        // **** 非压缩页 ****
        // 1- 得到一个空闲的 buf_block_t structure
        //   1.1 如果 free list 不为空，则返回第一个 block
        //   1.2 如果 free list 为空，从 LRU list 尾部向前遍历（至多100个）找到可以驱逐的数据页
        //   1.3 依然没有找到的话，从 LRU list 尾部刷脏一个数据页（buf_flush_single_page_from_LRU）
        |- buf_LRU_get_free_block
        |- buf_page_init      // 2- 初始化 buf_block_t 类型是 BUF_BLOCK_FILE_PAGE。将数据页加入到 page_hash
        |- buf_LRU_add_block  // 3- 将数据页加入到 LRU_list 中
        // 4- 获得数据页的 X-lock，这是一个"pass type" lock，由 IO handler 线程释放
        //    其他 reader 可以通过 尝试获得 S-lock 来等待此次 IO 完成
        |- rw_lock_x_lock(&block->lock）
        // **** 压缩页 ****
        |- buf_page_alloc_descriptor // 1- malloc(ut_zalloc_nokey) buf_page_t
        |- buf_buddy_alloc           // 2- 用 buddy 算法分配一块内存空间
        // 3- 初始化 buf_page_t 类型是 BUF_BLOCK_ZIP_PAGE
        // 4- 加入到 page_hash 和 LRU_list 中
        |- buf_LRU_add_block
     // Step-1.2.2：使用同步模式或异步模式从磁盘上读 Page
     |- fil_io
     // 数据页读上来之后的辅助工作（如果是同步模式，此时数据页已被读到 Buffer Pool 中）
     // 1- 检查数据页是否 corrupt
     // 2- Change Buffer Merge
     // ...（待补充）
     |- buf_page_io_complete
  // 如果模式是 IF_IN_POOL 或 PEEK_IF_IN_POOL，且数据页 io_fix 是 BUF_IO_READ（正在被读上来）
  // 直接返回 nullptr
  |- is_optimistic
   
  // Step-2：数据库状态检查（以及解压）
  |- Buf_fetch<T>::check_state
    // 对于BUF_BLOCK_ZIP_DIRTY类型的数据页（压缩页），解压之后初始化一个（新的） buf_block_t
    |- buf_relocate
   
  // Step-3：读线程之间的并发控制
  // 当读线程发现数据页在IO期间（io_fix = BUF_IO_READ），等待 IO 完成。实现类似于（优化的） busy-wait
  |- buf_wait_for_read
   
  // Step-4：获得 block->lock，之后可以该线程便可以使用数据页
  |- mtr_add_page
  
```