
# [InnoDB（十）：Buffer Pool]


## 基本概念

### Page

Page 通常称作数据页，是 InnoDB 中内存与磁盘交互的最小单位；也是 Buffer Pool中 逻辑链表的元素

```plain
buf_block_t {
  byte *frame // 指向数据页内容（一般为 16KB）
  BPageLock lock // 读写锁，保护数据页的内容
  ...
}
```

### Buffer Chunk

Buffer Chunks 是**由 Buffer Pool 管理**的一片连续的 _**内存区域**_，这里的管理是什么概念呢？

*   决定区域的**存储内容**（_控制结构体_、数据页）
*   决定存储内容的**结构**（控制结构体和控制结构体之间、控制结构体和数据页之间以多种链表相连）
*   决定存储内容的**变化**（控制结构体的产生、释放，数据页的产生、释放）
*   ......

  

![](assets/1591157630-dcac973a268ac5906558c28fda5ce54b.png)

  

Buffer Chunks 的构成：

*   **数据页的控制结构体**（Control Structure）：**buf\_block\_t** / **buf\_page\_t**（结构体的申请/释放都是以Pooling的形式）  
    buf\_page\_t 是 buf\_block\_t 的一部分。概括性的讲：
    *   buf\_block\_t 对应解压页
    *   buf\_page\_t 对应压缩页
*   **数据页**：磁盘上存储的是压缩页，大小可以是1K / 2K / 4K / 8K / 16K
*   **链表**：将大小相等的内存块（1K / 2K / 4K / 8K / 16K）连接在一起，供伙伴系统（Buddy System）使用

Buffer Chunks 的初始化是为每个 Buffer Chunks 分配一片内存区域，并在其上初始化 **buf\_block\_t** deacriptors（buf\_block\_t） 和 buf\_block\_t→ frame（真是的数据页内容）

```plain
buf_chunk_init {
  // 为Buffer Chunks分配一块内存
  chunk->mem_size = mem_size;
  chunk->mem = os_mem_alloc_large(&chunk->mem_size);
   
  // chunk->blocks指向内存的起始点
  // chunk->size是这块内存能保存的数据页的数量，每个数据页需要分配一个buf_block_t descriptor
  chunk->blocks = (buf_block_t*) chunk->mem;
  chunk->size = chunk->mem_size / UNIV_PAGE_SIZE
        - (frame != chunk->mem);
   
  // 将内存块分为两部分，第一部分保存buf_block_t descriptor，第二部分保存数据页的内存
  // 从内存块的起始处开始预留足够多的buf_block_t descriptor（每个数据页分配一个）
  while (frame < (byte*) (chunk->blocks + size)) {
     frame += UNIV_PAGE_SIZE;
     size--;
  }
 
  // 初始化这些buf_block_t ...
  // 并将buf_block_t->frame指向内存块第二部分中为其分配的大小为（UNIV_PAGE_SIZE）的内存区域
  block = chunk->blocks;
  for (i = chunk->size; i--; ) {
    buf_block_init(buf_pool, block, frame);
    block++;
    frame += UNIV_PAGE_SIZE;
    ...
  }
}
```

## 数据页

数据页（Page）是访问 Buffer Pool 的基本单位，由 structure buf\_block\_t（非压缩页） / buf\_page\_t（压缩页） 描述。在 Buffer Pool 中的数据页有六种状态。

               ![](assets/1591157630-bef5f62e0fce4a6a38d0aab9560be49c.jpg)

  

1.  BUF\_BLOCK\_NOT\_USED：在 free list 中的数据页
2.  BUF\_BLOCK\_READY\_FOR\_USED：从  free list 中移除，准备存放从磁盘读到的数据
3.  BUF\_BLOCK\_ZIP\_PAGE：从磁盘读上来的是压缩页，或者在 Buffer Pool 中的解压页被驱逐，但保留压缩页
4.  BUF\_BLOCK\_ZIP\_DIRTY：在 Buffer Pool 中的解压页被驱逐，但保留压缩页且该页是脏页
5.  BUF\_BLOCK\_FILE\_PAGE：从磁盘读上来的是非压缩页，或者读上来的压缩页被解压
6.  BUF\_BLOCK\_REMOVE\_HASH：数据页被驱逐，从 page hash 中移除

## Buffer Pool 的基本操作

Buffer Pool 本质上是一个 Cache，提供读 / 写两种基本操作

### 通过 Buffer Pool 得到数据页 - READ

在 Buffer Pool 里查找数据页，若没有则从磁盘中读到 Buffer Pool 里。函数 buf\_page\_get\_gen 

```java
// 从 Buffer Pool 或磁盘上获得一个 Page。Page fetch mode：
//   1-NORMAL：若不在 BP 中则从磁盘文件载入到 BP 中
//   2-SCAN：同 NORMAL，但是暗示这是一次大规模的扫描（e.g Table Scan）
//   3-IF_IN_POOL：只在 BP 中查找没，如果不在则返回
//   4-PEEK_IF_IN_POOL：同 IF_IN_POOL，但不要将数据页放在 LRU list young 区域
//   5-IF_IN_POOL_OR_WATCH：同 IF_IN_POOL，但如果不在则设置数据页为 "watch"（与 purge 线程有关）
//   NO_LATCH/POSSIBLY_FREED... 暂不明确
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
      //   1- 结构体 buf_block_t/buf_page_t 已经在 Buffer Pool 中（数据页正在被读上来，或已经在 Buffer Pool
      //      中. 表示可能被其他的 reader "抢先"）
      //   2- 表空间在被删除过程中
      //   3- 模式是 BUF_READ_IBUF_PAGES_ONLY（只读 ibuf 数据页），但 page_id 并不属于 ibuf B-tree
      //     （ibuf_page_low）
      |- buf_page_init_for_read
        // **** 非压缩页 ****
        // 1- 得到一个空闲的 buf_block_t structure
        //   1.1 如果 free list 不为空，则返回第一个 block
        //   1.2 如果 free list 为空，从 LRU list 尾部向前遍历（至多100个）找到可以驱逐的数据页
        //   1.3 依然没有找到的话，从 LRU list 尾部刷脏一个数据页（buf_flush_single_page_from_LRU）
        |- buf_LRU_get_free_block
        |- buf_page_init      // 2- 初始化 buf_block_t 类型是 BUF_BLOCK_FILE_PAGE。将数据页加入到 page_hash 中
        |- buf_LRU_add_block  // 3- 将数据页加入到 LRU_list 中
        // 4- 获得数据页的 X-lock，这是一个"pass type" lock，由 IO handler 线程释放
        //    其他 reader 可以通过 尝试获得 S-lock 来等待此次 IO 完成
        |- rw_lock_x_lock(&block->lock）
        // **** 压缩页 ****
        |- buf_page_alloc_descriptor // 1- malloc(ut_zalloc_nokey) buf_page_t
        |- buf_buddy_alloc           // 2- 用 buddy 算法分配一块内存空间
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

### Buffer Pool 的脏页持久化 - WRITE

如果打开 double write 的话，Buffer Pool 刷脏有一个约束，**一定要保证数据页已在 double write 中持久化，再将数据页持久化**

注意，double write 的写都是批量的、顺序的。系统表空间中的 double write 为 2M。这里的行为是：

1.  使用同步 IO（fil\_io 参数 sync = true）将脏页写到 系统表空间中的 double write 区域
2.  使用异步 IO （fil\_io 参数 sync = false）将脏页写到用户表空间中

```plain
// 将 LRU list / flush list 上的一个脏页持久化
buf_flush_write_block_low
  // 设置 IO 状态为 BUF_IO_WRITE
  |- buf_page_set_io_fix
  // 将 Buffer Pool 中的一个脏页持久化（写回磁盘）
  |- buf_flush_write_block_low
    // WAL的保证：确定在 page->newest_modification 之前的日志都已经持久化
    |- log_write_up_to
    // 这里要分三种情况：
    // 1- 关闭 double write / 只读模式（srv_read_only_mode） / 临时表
    //    以异步IO模式写回磁盘，不经过 double write
    |- fil_io
    // 2- 在 LRU list 尾部刷脏一个数据页（flush_type 是 BUF_FLUSH_SINGLE_PAGE）
    // 在 buf_LRU_get_free_block 里可能存在这种情况，见上文
    |- buf_dblwr_write_single_page
    // 3- 其他情况（一般的 page cleaner 刷脏页），将脏页加入到 double write buffer 中
    // 而不急于写到系统表空间的 double write 区域
    |- buf_dblwr_add_to_batch
      // 3-1. 当 double write buffer 写满后，将其中的内容*同步的*（sync=true）写到系统表空间 double write 区域
      // 并调用 fsync
      |- buf_dblwr_flush_buffered_writes
        |- fil_io & fil_flush(TRX_SYS_SPACE)
        // 将对应的数据页*异步的*（sync=false, InnoDB simulated AIO）写回到用户表空间中
        // 并当数据页落盘后，在 buf_page_io_complete 中将数据页其从 flush list 上移除
        |- buf_dblwr_write_block_to_datafile
      // 3-2. 当 double write buffer 还有空余，将数据页直接拷贝到 double write buffer 中
      |- memcpy (buf_dblwr->write_buf ...)
```

### Page Cleaner 线程

Page Cleaner 线程定期的将 Buffer Pool 中的一批脏页持久化。一个 page cleaner coordinator thread 和若干个（srv\_n\_page\_cleaners）page cleaner worker thread。分别对应着函数 buf\_flush\_page\_coordinator\_thread 和 buf\_flush\_page\_cleaner\_thread

（未完待续）

## Buffer Pool 的并发控制

### buf\_block\_t / buf\_page\_t 结构体的说明

在 buf\_block\_t 和 buf\_page\_t 中有若干种锁（latch）

```plain
buf_block_t {
  // 互斥的访问 frame（数据页的指针）的读写锁
  BPageLock lock;
   
  // 互斥的访问及修改其他变量 state / buf_fix_count / io_fix
  BPageMutex mutex;
}
```

**TODO**：buf\_fix\_count / io\_fix 的分析

### 数据页的并发访问

Buffer Pool 的并发控制是一个复杂的话题。多个线程请求相同的数据页时，如果数据页不在 Buffer Pool 中，是否可能引发对同一个数据页并发的磁盘文件 IO ？ **不会**

一个典型的读流程是（buf\_page\_get\_gen）：

1.  在 Buffer Pool 中分配一个空闲 buf\_block\_t 来代表即将被载入的数据页
2.  在 page hash 中查看是否有这个数据页，若没有，到 Step-3；否则退出
3.  初始化 buf\_block\_t（e.g 类型是 BUF\_BLOCK\_FILE\_PAGE）
4.  设置 buf\_block\_t→ io\_fix = **BUF\_IO\_READ**
5.  将 buf\_block\_t 加入到 page\_hash 和 LRU\_list 中
6.  使用同步模式将文件中数据页读到 Buffer Pool 指定区域，并将 buf\_block\_t→ frame 指向该页
7.  设置 buf\_block\_t→ io\_fix = **BUF\_IO\_NONE**

当其他线程也想请求相同数据页时，首先如果看到 page hash中已经有对应的 buf\_block\_t（Step-2），说明数据页 _已经_ 或 _正被载入_ Buffer Pool。**若 buf\_block\_t→****`io_fix 是` `BUF_IO_READ`****，说明有 pending IO**。则该线程需等待 IO 完成（buf\_wait\_for\_read）。即通过 buf\_block\_t→ io\_fix 保证多个线程的互斥

那么其他线程是如何等待 IO 完成的呢？这里涉及到 C++ 内存结构模型中的 acquire / release 语义

```plain
buf_wait_for_read {
  for (;;) {
    // BUF_IO_READ 表示有 Pending IO，等到 IO 完成
    if (block->io_fix == BUF_IO_READ) {
      // 这里采取的办法是忙等待（busy-wait），但得到 io_fix 确实"脏读"
      // 因此可能出现读到的是"旧值"，由于 io_fix 是 enum 类型，所以不存在"撕裂"问题
      // 由于将 io_fix 由 BUF_IO_NONE 修改为 BUF_IO_READ 时持有 block->lock，此时再通过获得 block->lock
      // 相当于一次 CPU cache 的刷新，能读到 io_fix 最新值
      if (s_lock(block->lock))
        s_unlock(block->lock);
      else
        sleep(20us);
    } else {
      // BUF_IO_NONE 说明 IO 已经完成
      break;
    }
  } // for
}
```

  

## 参考

*   [MySQL · 源码分析 · Innodb缓冲池刷脏的多线程实现](http://mysql.taobao.org/monthly/2018/09/02/)
*   [MySQL · 引擎特性 · InnoDB Buffer Pool](http://mysql.taobao.org/monthly/2017/05/01/)
*   [InnoDB原生Checkpoint策略及各版本优化详解](http://hedengcheng.com/?p=88)
*   [MySQL · 引擎特性 · InnoDB 文件系统之IO系统和内存管理](http://mysql.taobao.org/monthly/2016/02/02/)

