#1.struct log_t

```cpp

/** Redo log buffer */
struct log_t{
...
    lsn_t        lsn;        /*!< log sequence number */
    ulint        buf_free;    //在日志缓冲中，第一个空闲位置
...
    byte*        buf_ptr;    /* unaligned log buffer */  //REDO缓存区相关定义
    byte*        buf;        /*!< log buffer */
    ulint        buf_size;    /*!< log buffer size in bytes */
    ulint        max_buf_free;    /*!< recommended maximum value ofbuf_free,
     after which the buffer isflushed */
...
    UT_LIST_BASE_NODE_T(log_group_t)log_groups;    //日志组
#ifndef UNIV_HOTBACKUP //定义了很多LSN即lsn_t，以表示在缓存区中对缓存区的不同类型的操作在
缓冲区中指向的逻辑位置
...
    lsn_t        write_lsn;    /*!< last written lsn */
    lsn_t        current_flush_lsn;/*!< end lsn for the current runningwrite +
                 flush operation */
    lsn_t        flushed_to_disk_lsn; /*!< how far we have written the logAND
                  flushed to disk *///从缓存区到存储，实现REDO的重要标识
...
    /** Fields involved in checkpoints @{ */
    lsn_t        log_group_capacity; /*!< capacity of the log group; ifthe
                  checkpoint age exceeds this, it is
                    a serious error because it is possiblewe will then overwrite
                     log and spoilcrash recovery */
    lsn_t        max_modified_age_async;
    lsn_t        max_modified_age_sync;
    lsn_t        max_checkpoint_age_async;
    lsn_t        max_checkpoint_age;
...
    lsn_t        last_checkpoint_lsn; /*!< latest checkpoint lsn */
    lsn_t        next_checkpoint_lsn; /*!< next checkpoint lsn */
...
#endif /* !UNIV_HOTBACKUP */
...
};

```