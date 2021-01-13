#1.struct log_t

```cpp
/** Redo log buffer */
struct alignas(INNOBASE_CACHE_LINE_SIZE) log_t
{
    /*!< log sequence number */
    lsn_t       lsn;

    /*!< first free offset within the log
    buffer in use */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    ulint       buf_free;

#ifndef UNIV_HOTBACKUP
    /*!< mutex protecting the log */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    LogSysMutex mutex;

    /*!< mutex protecting writing to log
    file and accessing to log_group_t */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    LogSysMutex write_mutex;

    /*!< mutex protecting writing flushed_to_disk_lsn */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    LogSysMutex flush_mutex;

    /*!< mutex protecting log task */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    LogSysMutex task_mutex;

    /*!< mutex to serialize access to
    the flush list when we are putting
    dirty blocks in the list. The idea
    behind this mutex is to be able
    to release log_sys->mutex during
    mtr_commit and still ensure that
    insertions in the flush_list happen
    in the LSN order. */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    FlushOrderMutex log_flush_order_mutex;
#endif /* !UNIV_HOTBACKUP */

    /**********************************************************************
    ************************ Fileds from MySQL 8.x below ******************
    ***********************************************************************/
    /** Current sn value. Used to reserve space in the redo log,
    and used to acquire an exclusive access to the log buffer.
    Represents number of data bytes that have ever been reserved.
    Bytes of headers and footers of log blocks are not included.
    Protected by: sn_lock.
    @see @ref subsect_redo_log_sn */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    atomic_sn_t sn;

    /** The recent written buffer.
    Protected by: sn_lock or writer_mutex. */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    Link_buf<lsn_t> recent_written;

    /** Sharded rw-lock which can be used to freeze redo log lsn.
    When user thread reserves space in log, s-lock is acquired.
    Log archiver (Clone plugin) acquires x-lock. */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    Sharded_rw_lock sn_lock;

    /** Approx. number of requests to write/flush redo since startup. */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    std::atomic<uint64_t> write_to_file_requests_total;

    /** How often redo write/flush is requested in average.
    Measures in microseconds. Log threads do not spin when
    the write/flush requests are not frequent. */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    std::atomic<uint64_t> write_to_file_requests_interval;

    /** Event used by the log writer thread to notify the log write
    notifier thread, that it should proceed with notifying user threads
    waiting for the advanced write_lsn (because it has been advanced). */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    os_event_t  write_notifier_event;

    /** Event used by the log flusher thread to notify the log flush
    notifier thread, that it should proceed with notifying user threads
    waiting for the advanced flushed_to_disk_lsn (because it has been
    advanced). */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    os_event_t  flush_notifier_event;

    /** Event used by the log flusher thread to notify the log flush
    notifier thread, that it should proceed with notifying user threads
    waiting for the advanced flushed_to_disk_lsn (because it has been
    advanced). */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    os_event_t  flush_notifier_event_async;

    /** Indicates whether the log write thread is actually waiting. */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    std::atomic_bool writer_wait;

    /** Indicates whether the log flush thread is actually waiting. */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    std::atomic_bool flusher_wait;

    /** Maximum sn up to which there is free space in both the log buffer
    and the log files. This is limitation for the end of any write to the
    log buffer. Threads, which are limited need to wait, and possibly they
    hold latches of dirty pages making a deadlock possible.
    Protected by: writer_mutex (writes). */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    atomic_sn_t sn_limit_for_end;

    /** Maximum sn up to which there is free space in both the log buffer
    and the log files for any possible mtr. This is limitation for the
    beginning of any write to the log buffer. Threads check this limitation
    when they are outside mini transactions and hold no latches. The formula
    used to calculate the limitation takes into account maximum size of mtr
    and thread concurrency to include proper margins and avoid issue with
    race condition (in which all threads check the limitation and then all
    proceed with their mini transactions).
    Protected by: writer_mutex (writes). */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    atomic_sn_t sn_limit_for_start;

    /** Used for stopping the log background threads. */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    std::atomic_bool should_stop_threads;

    /** Event used by the tidb task thread */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    os_event_t  task_event;

    /** Size of the log buffer expressed in number of data bytes,
    that is excluding bytes for headers and footers of log blocks. */
    atomic_sn_t buf_size_sn;

    /** Capacity of log files excluding headers of the log files.
    If the checkpoint age exceeds this, it is a serious error,
    because in such case we have already overwritten redo log. */
    lsn_t lsn_real_capacity;

    /** Capacity of redo log files for log writer thread. The log writer
    does not to exceed this value. If space is not reclaimed after 1 sec
    wait, it writes only as much as can fit the free space or crashes if
    there is no free space at all (checkpoint did not advance for 1 sec). */
    lsn_t lsn_capacity_for_writer;

    /** When this margin is being used, the log writer decides to increase
    the concurrency_margin to stop new incoming mini transactions earlier,
    on bigger margin. This is used to provide adaptive concurrency margin
    calculation, which we need because we might have unlimited thread
    concurrency setting or we could miss some log_free_check() calls.
    It is just best effort to help getting out of the troubles. */
    lsn_t extra_margin;

    /** Capacity of the log files available for log_free_check(). */
    lsn_t lsn_capacity_for_free_check;

    /** Maximum allowed concurrency_margin. We never set higher, even when we
    increase the concurrency_margin in the adaptive solution. */
    lsn_t max_concurrency_margin;

    /** Margin used in calculation of @see sn_limit_for_start.
    Protected by: writer_mutex. */
    atomic_sn_t concurrency_margin;

    /** Unaligned pointer to array with events, which are used for
    notifications sent from the log write notifier thread to user threads.
    The notifications are sent when write_lsn is advanced. User threads
    wait for write_lsn >= lsn, for some lsn. Log writer advances the
    write_lsn and notifies the log write notifier, which notifies all users
    interested in nearby lsn values (lsn belonging to the same log block).
    Note that false wake-ups are possible, in which case user threads
    simply retry waiting. */
    os_event_t  *write_events;

    /** Number of entries in the array with writer_events. */
    ulint       write_events_size;

    /** Unaligned pointer to array with events, which are used for
    notifications sent from the log flush notifier thread to user threads.
    The notifications are sent when flushed_to_disk_lsn is advanced.
    User threads wait for flushed_to_disk_lsn >= lsn, for some lsn.
    Log flusher advances the flushed_to_disk_lsn and notifies the
    log flush notifier, which notifies all users interested in nearby lsn
    values (lsn belonging to the same log block). Note that false
    wake-ups are possible, in which case user threads simply retry
    waiting. */
    os_event_t* flush_events;

    /** Number of entries in the array with events. */
    ulint       flush_events_size;

    /** True iff the log writer thread is alive. */
    std::atomic_bool write_thread_alive;

    /** True iff the log flusher thread is alive. */
    std::atomic_bool flush_thread_alive;

    /**********************************************************************
    ************************ Fileds from MySQL 8.x above ******************
    ***********************************************************************/

    /* Alignas fileds declared below to avoiding false sharing in MySQL 5.7 */

    /*!< log buffer currently in use; this could point to either the first
    half of the aligned(buf_ptr) or the second half in turns, so that log
    write/flush to disk don't block concurrent mtrs which will write
    log to this buffer */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    byte*       buf;

    /*!< last written lsn */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    atomic_lsn_t    write_lsn;

    /*!< how far we have written the log AND flushed to disk */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    atomic_lsn_t    flushed_to_disk_lsn;

    /*!< this event is signaled for flushing thread, protected by the log
    write mutex */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    os_event_t  flush_event;

    /*!< event to signal write thread to start after recovery or write log
    after mtr_commit, protected by the log mutex */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    os_event_t  write_event;

    /*!< event to signal log rpl thread to send log to slave node */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    os_event_t  rpl_event;

    /*!< Time stats for trx waiting for log flush */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    uint64_t    flush_time;

    /*!< Time stats for trx waiting for log flush */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    ulint       flush_num;

#ifdef tidb_DB_UTEST
    /*!< flush sync event for utest mode */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    os_event_t  local_sync_event;

    /*!< filed to deliver flushed lsn to log finish thread */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    atomic_lsn_t    flushed_lsn;
#endif /* tidb_DB_UTEST */

    /*!< number of mtrs after last checksum log */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    ulint       log_checksum_window;

    /*!< set true if some mtrs will record checksum */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    bool        log_need_checksum;

    /*!< end lsn for the current running write + flush operation */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    lsn_t       current_flush_lsn;

    /*!< log wait queue for async log flushing */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    LogWaitQueue*   wait_queue;

    /*!< None aligned pointer for wait queue */
    alignas(INNOBASE_CACHE_LINE_SIZE)
    aligned_pointer<LogWaitQueue>*  wait_queue_obj;

    byte*       buf_ptr;    /*!< unaligned log buffer, which should
                    be of double of buf_size */
    bool        first_in_use;   /*!< true if buf points to the first
                    half of the aligned(buf_ptr), false
                    if the second half */
    ulint       buf_size;   /*!< log buffer size of each in bytes */
    ulint       max_buf_free;   /*!< recommended maximum value of
                    buf_free for the buffer in use, after
                    which the buffer is flushed */
    bool        check_flush_or_checkpoint;
                    /*!< this is set when there may
                    be need to flush the log buffer, or
                    preflush buffer pool pages, or make
                    a checkpoint; this MUST be TRUE when
                    lsn - last_checkpoint_lsn >
                    max_checkpoint_age; this flag is
                    peeked at by log_free_check(), which
                    does not reserve the log mutex */
    bool        check_load_ctrl;
                    /*!< this is set when log compensation
                    thread is running, which does not
                    reserve the log mutex */
    UT_LIST_BASE_NODE_T(log_group_t)
            log_groups; /*!< log groups */

#ifndef UNIV_HOTBACKUP
    /** The fields involved in the log buffer flush @{ */

    ulint       buf_next_to_write;/*!< first offset in the log buffer
                    where the byte content may not exist
                    written to file, e.g., the start
                    offset of a log record catenated
                    later; this is advanced when a flush
                    operation is completed to all the log
                    groups */
    volatile bool   is_extending;   /*!< this is set to true during extend
                    the log buffer size */
    ulint       n_pending_flushes;/*!< number of currently
                    pending flushes; incrementing is
                    protected by the log mutex;
                    may be decremented between
                    resetting and setting flush_event */
    ulint       n_log_ios;  /*!< number of log i/os initiated thus
                    far */
    ulint       n_log_ios_old;  /*!< number of log i/o's at the
                    previous printout */
    time_t      last_printout_time;/*!< when log_print was last time
                    called */
    /* @} */

    /** Fields involved in checkpoints @{ */
    lsn_t       log_group_capacity; /*!< capacity of the log group; if
                    the checkpoint age exceeds this, it is
                    a serious error because it is possible
                    we will then overwrite log and spoil
                    crash recovery */
    lsn_t       max_modified_age_async;
                    /*!< when this recommended
                    value for lsn -
                    buf_pool_get_oldest_modification()
                    is exceeded, we start an
                    asynchronous preflush of pool pages */
    lsn_t       max_modified_age_sync;
                    /*!< when this recommended
                    value for lsn -
                    buf_pool_get_oldest_modification()
                    is exceeded, we start a
                    synchronous preflush of pool pages */
    lsn_t       max_checkpoint_age_async;
                    /*!< when this checkpoint age
                    is exceeded we start an
                    asynchronous writing of a new
                    checkpoint */
    lsn_t       max_checkpoint_age;
                    /*!< this is the maximum allowed value
                    for lsn - last_checkpoint_lsn when a
                    new query step is started */
    ib_uint64_t next_checkpoint_no;
                    /*!< next checkpoint number */
    lsn_t       last_checkpoint_lsn;
                    /*!< latest checkpoint lsn,same as the current VDL */
    lsn_t       next_checkpoint_lsn;
                    /*!< next checkpoint lsn */
    mtr_buf_t*  append_on_checkpoint;
                    /*!< extra redo log records to write
                    during a checkpoint, or NULL if none.
                    The pointer is protected by
                    log_sys->mutex, and the data must
                    remain constant as long as this
                    pointer is not NULL. */
    ulint       n_pending_checkpoint_writes;
                    /*!< number of currently pending
                    checkpoint writes */
    rw_lock_t   checkpoint_lock;/*!< this latch is x-locked when a
                    checkpoint write is running; a thread
                    should wait for this without owning
                    the log mutex */
#endif /* !UNIV_HOTBACKUP */
    byte*       checkpoint_buf_ptr;/* unaligned checkpoint header */
    byte*       checkpoint_buf; /*!< checkpoint header is read to this
                    buffer */
    /* @} */

    lsn_t       hist_lsn;       /*!< the start lsn of the history
                        log when complete the fetching,
                        set when fetch_complete is set
                        to true */
    lsn_t       protect_lsn;        /*!< log writer could not write
                        beyond the lsn if fetch_complete
                        is still false */
    lsn_t       hist_clean_lsn;     /*!< logs which lsn large than
                        this lsn have overwrote all the
                        history logs in ring buffer,
                        thus we could release the purge
                        coordinator because we could not
                        provide any history log for any
                        slave node who relogin since
                        that time, and the relogin must
                        failed for NODE_ERR_LOG_LACK */
    bool        fetch_complete;     /*!< true if the history log
                        fetching has complete, protected
                        by log write mutex */
    bool        write_rbuf;     /*!< true if ring buffer can be written,
                        protected by wtite mutex */
    byte*       compensate_buf;     /*!< compensation buffer */
    lsn_t       compensate_lsn;     /*!< compensation lsn when write_rbuf is false */
    os_event_t  compensate_event;   /*!< event to signal log compensate
                        compensation thread */

    atomic_lsn_t    recycle_lsn;        /* The lsn what base pages could
                        be advanced up to in the storage */

    uint64_t    vdl_ts;         /* The timestamp for the latest
                        vdl we get from get_VDL */
#ifdef tidb_DB_UTEST
    byte*       compensate_check_buf1;
    byte*       compensate_check_buf2;
    ulint       check_ptr1;
    ulint       check_ptr2;
#endif /* tidb_DB_UTEST */
};

                                                            
```