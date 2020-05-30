
# [InnoDB（二）：Checkpoint]


## 什么是Checkpoint ？

我们都知道InnoDB采用WAL的方式，并且每条事务日志（Redo日志）是以LSN唯一标识。Checkpoint的目的是产生一个**Checkpoint\_LSN**，并保证：

*   **持久化Checkpoint\_LSN（崩溃恢复时使用）**
*   **所有LSN < Checkpoint\_LSN的事务日志产生的修改已经持久化（脏页已刷写入磁盘，表示这部分事务日志可以删除）**

## 为什么要做Checkpoint ？

做Checkpoint主要会有三个收益：

*   【缩短InnoDB的崩溃恢复时间】数据库崩溃恢复时，不需要重做所有的Redo日志：因为Checkpoint 之前的脏页都已经刷写到磁盘，只需对Checkpoint后的Redo日志进行恢复即可，这样就大大缩短了崩溃恢复的时间
    
*   【减少Buffer Pool中的使用量】当Buffer Pool不够用时，会根据LRU算法淘汰最近最少使用的页，若此页为脏页，那么需要强制执行Checkpoint，将脏页刷回磁盘。
    
*   【支持Redo日志的循环写策略】当前数据库对 Redo日志的设计都是循环使用的，为了防止被覆盖，需要Checkpoint的支持。
    

## InnoDB如何做Checkpoint ?

InnoDB有两种Checkpoint还包含另一个含义：将Buffer Pool中的部分脏页刷写到磁盘。所以

Checkpoint实现起来容易划分为两个过程：

*   【1】产生一个Checkpoint\_LSN
*   【2】保证所有LSN<Checkpoint\_LSN的事务日志全部已经应用

#### 函数：log\_checkpoint

log\_checkpoint函数会产生一个**Checkpoint\_LSN**，并保证所有LSN < Checkpoint\_LSN的事务日志产生的修改已经持久化

下面的代码分析会略去部分细节

```plain
/******************************************************//**
Makes a checkpoint. Note that this function does not flush dirty
blocks from the buffer pool: it only checks what is lsn of the oldest
modification in the pool, and writes information about the lsn in
log files. Use log_make_checkpoint_at to flush also the pool.
@return TRUE if success, FALSE if a checkpoint write was already running */
UNIV_INTERN
ibool
log_checkpoint(
/*===========*/
    ibool   sync,       /*!< in: TRUE if synchronous operation is
                desired */
    ibool   write_always)   /*!< in: the function normally checks if the
                the new checkpoint would have a greater
                lsn than the previous one: if not, then no
                physical write is done; by setting this
                parameter TRUE, a physical write will always be
                made to log files */
{
    ...
    // flush_list上的每个Page都有一个modified_block_lsn，表示修改过这个Page的最小的lsn（Page载入内存后第一次修改Page的lsn）
    // 遍历flush_list，找到flush list上所有Page中最小的modified_block_lsn，作为smallest_modified_block_lsn，那么：
    oldest_lsn = log_buf_pool_get_oldest_modification();
     
    // log_write_up_to(lsn_t lsn, ulint wait, ibool flush_to_disk)函数是将Redo Log Buffer中小于lsn的所有日志记录都写入到Redo日志文件（文件的操作系统缓冲区）中，根据flush_to_disk确定会不会写到磁盘上
    // 这里将flush_to_disk设置为TRUE，确保lsn < oldest_lsn的日志都写入到磁盘上
    // 这里要确定一个问题：lsn < oldest_lsn的所有日志应用到的Page是否已经全部持久化？或者说这些日志是否可以删除？
    // 因为modified_block_lsn表示修改过这个Page的最小lsn，如果一个日志记录的lsn < smallest_modified_block_lsn的日志记录修改的Page都没在flush list上=>表明这个日志记录修改的Page不是脏页，即已经在磁盘上
    // 当然，flush list上的一个Page也可能被多个日志记录更改过，假设log0（lsn=10）和log1(lsn=20)修改过Page0，那么Page0.modified_block_lsn=10，则oldest_lsn一定小于10, log0和log1应用到的Page（Page0）没有被持久化，而且也没有小于oldest_lsn，符合现实
    // lsn > smallest_modified_block_lsn的日志记录可能有的在flush list上，有的在磁盘上 
    // 【注意】此处为何还要调用log_write_up_to？难道不能保证oldest_lsn之前的日志已全部刷盘？
    // 因为函数log_buf_pool_get_oldest_modification中，如果flush list为空，oldest_lsn = log_sys->lsn
    // 并不能保证log_sys->lsn之前的日志已全部刷盘
    log_write_up_to(oldest_lsn, LOG_WAIT_ALL_GROUPS, TRUE); 
  
    // 将oldest_lsn赋值给log_sys->next_checkpoint_lsn，下一步会将log_sys->next_checkpoint_lsn写入到磁盘的Redo日志文件中
    log_sys->next_checkpoint_lsn = oldest_lsn;
  
    // 把next_checkpoint_lsn写入第一个日志文件的LOG FILE Header中
    // 奇数次的Checkpoint写到LOG_CHECKPOINT_1（OS_FILE_LOG_BLOCK_SIZE，512）偏移处
    // 偶数次的Checkpoint写到LOG_CHECKPOINT_2（3*OS_FILE_LOG_BLOCK_SIZE，3*512）偏移处
    log_groups_write_checkpoint_info();
}
```

#### 函数：log\_make\_checkpoint\_at

log\_checkpoint不会将flush list上的脏页写入磁盘，而log\_make\_checkpoint\_at会将一部分（取决于函数的参数lsn）flush list上的脏页写入磁盘，如果传入LSN\_MAX（最大的64位整数），表示将全部脏页写入磁盘

因此log\_make\_checkpoint\_at函数的作用是：

*   将一部分脏页写回磁盘
*   产生一个Checkpoint\_LSN，所有LSN < Checkpoint\_LSN的事务日志产生的修改已经持久化

```plain
/****************************************************************//**
Makes a checkpoint at a given lsn or later. */
UNIV_INTERN
void
log_make_checkpoint_at(
/*===================*/
    lsn_t   lsn,        /*!< in: make a checkpoint at this or a
                later lsn, if LSN_MAX, makes
                a checkpoint at the latest lsn */
    ibool   write_always)   /*!< in: the function normally checks if
                the new checkpoint would have a
                greater lsn than the previous one: if
                not, then no physical write is done;
                by setting this parameter TRUE, a
                physical write will always be made to
                log files */
{
    /* Preflush pages synchronously */
    // 将flush list上modified_block_lsn < lsn的Page写入磁盘
    while (!log_preflush_pool_modified_pages(lsn)) {
        /* Flush as much as we can */
    }
 
    while (!log_checkpoint(TRUE, write_always)) {
        /* Force a checkpoint */
    }
}
```

## 什么时候Checkpoint ?

### 全部Checkpoint：

将Buffer Pool中所有脏页刷回磁盘

*   MySQL Shutdown：log\_make\_checkpoint\_at(LSN\_MAX, TRUE)，将flush list上全部Page写回磁盘
    
*   Reset Logs：log\_make\_checkpoint\_at(LSN\_MAX, TRUE);
    
*   创建DoubleWrite Buffer：log\_make\_checkpoint\_at(LSN\_MAX, TRUE);

### 部分Checkpoint：

将Buffer Pool中部分脏页刷回磁盘

#### Master Thread

每7秒执行一次log\_checkpoint，只调用log\_checkpoint

```plain
xtern "C" UNIV_INTERN
os_thread_ret_t
DECLARE_THREAD(srv_master_thread)(
/*==============================*/
    void*   arg __attribute__((unused)))
{
    ...
    while (srv_shutdown_state == SRV_SHUTDOWN_NONE) {
        // 休眠1秒钟
        srv_master_sleep();
 
        MONITOR_INC(MONITOR_MASTER_THREAD_SLEEP);
 
        if (srv_check_activity(old_activity_count)) {
            old_activity_count = srv_get_activity_count();
            // srv_master_do_active_tasks / srv_master_do_idle_tasks函数里会判断当前时间能否被SRV_MASTER_CHECKPOINT_INTERVAL整除，SRV_MASTER_CHECKPOINT_INTERVAL为7
            srv_master_do_active_tasks();
        } else {
            srv_master_do_idle_tasks();
        }
    }
    ...
}
```



