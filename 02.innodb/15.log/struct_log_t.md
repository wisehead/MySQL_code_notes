#1.struct log_t

```cpp
/** Redo log buffer */
struct log_t{
    byte pad[64];   /*!< padding to prevent other memory
                    update hotspots from residing on the
                    same memory cache line */
#ifndef UNIV_HOTBACKUP

    /** Sharded rw-lock which can be used to freeze redo log lsn.
    When user thread reserves space in log, s-lock is acquired.
    Log archiver (Clone plugin) acquires x-lock. */
    Sharded_rw_lock sn_lock;

    alignas(CACHE_LINE_SIZE)
    /** Current sn value. Used to reserve space in the redo log,
    and used to acquire an exclusive access to the log buffer.
    Represents number of data bytes that have ever been reserved.
    Bytes of headers and footers of log blocks are not included.
    Protected by: sn_lock.
    @see @ref subsect_redo_log_sn */
    atomic_sn_t sn;

    /** Padding after the _sn to avoid false sharing issues for
    constants below (due to changes of sn). */
    alignas(CACHE_LINE_SIZE)
    /** Pointer to the log buffer, aligned up to OS_FILE_LOG_BLOCK_SIZE.
    The alignment is to ensure that buffer parts specified for file IO write
    operations will be aligned to sector size, which is required e.g. on
    Windows when doing unbuffered file access.
    Protected by: sn_lock. */
    aligned_array_pointer<byte, OS_FILE_LOG_BLOCK_SIZE> buf;
    alignas(CACHE_LINE_SIZE)
    /** The recent written buffer.
    Protected by: sn_lock or writer_mutex. */
    Link_buf<lsn_t> recent_written;

    alignas(CACHE_LINE_SIZE)
    /** The recent closed buffer.
    Protected by: sn_lock or closer_mutex. */
    Link_buf<lsn_t> recent_closed;
    alignas(CACHE_LINE_SIZE)

    /** Maximum sn up to which there is free space in both the log buffer
    and the log files for any possible mtr. This is limitation for the
    beginning of any write to the log buffer. Threads check this limitation
    when they are outside mini transactions and hold no latches. The formula
    used to calculate the limitation takes into account maximum size of mtr
    and thread concurrency to include proper margins and avoid issue with
    race condition (in which all threads check the limitation and then all
    proceed with their mini transactions).
    Protected by: writer_mutex (writes). */
    atomic_sn_t sn_limit_for_start;

    /** Maximum sn up to which there is free space in both the log buffer
    and the log files. This is limitation for the end of any write to the
    log buffer. Threads, which are limited need to wait, and possibly they
    hold latches of dirty pages making a deadlock possible.
    Protected by: writer_mutex (writes). */
    atomic_sn_t sn_limit_for_end;

    /** Margin used in calculation of @see sn_limit_for_start. */
    atomic_sn_t concurrency_margin;

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

    /** True if we haven't increased the concurrency_margin since we entered
    (lsn_capacity_for_margin_inc..lsn_capacity_for_writer] range. This allows
    to increase the margin only once per issue and wait until the issue becomes
    resolved, still having an option to increase margin even more, if new issue
    comes later. */
    bool concurrency_margin_ok;

    /** Maximum allowed concurrency_margin. We never set higher, even when we
    increase the concurrency_margin in the adaptive solution. */
    lsn_t max_concurrency_margin;

    alignas(CACHE_LINE_SIZE)
    /** Up to this lsn, data has been written to disk (fsync not required).
    Protected by: writer_mutex (writes).
    @see @ref subsect_redo_log_write_lsn */
    atomic_lsn_t write_lsn;

    alignas(CACHE_LINE_SIZE)
    /** Unaligned pointer to array with events, which are used for
    notifications sent from the log write notifier thread to user threads.
    The notifications are sent when write_lsn is advanced. User threads
    wait for write_lsn >= lsn, for some lsn. Log writer advances the
    write_lsn and notifies the log write notifier, which notifies all users
    interested in nearby lsn values (lsn belonging to the same log block).
    Note that false wake-ups are possible, in which case user threads
    simply retry waiting. */
    os_event_t *write_events;

    /** Number of entries in the array with writer_events. */
    size_t write_events_size;

    alignas(CACHE_LINE_SIZE)
    /** Unaligned pointer to array with events, which are used for
    notifications sent from the log flush notifier thread to user threads.
    The notifications are sent when flushed_to_disk_lsn is advanced.
    User threads wait for flushed_to_disk_lsn >= lsn, for some lsn.
    Log flusher advances the flushed_to_disk_lsn and notifies the
    log flush notifier, which notifies all users interested in nearby lsn
    values (lsn belonging to the same log block). Note that false
    wake-ups are possible, in which case user threads simply retry
    waiting. */
    os_event_t *flush_events;

    /** Number of entries in the array with events. */
    size_t flush_events_size;
    /** Padding before the frequently updated flushed_to_disk_lsn. */
    alignas(CACHE_LINE_SIZE)
    /** Up to this lsn data has been flushed to disk (fsynced). */
    atomic_lsn_t    flushed_to_disk_lsn;
    /** Padding after the frequently updated flushed_to_disk_lsn. */

    alignas(CACHE_LINE_SIZE)
    /** Last flush start time. Updated just before fsync starts. */
    Log_clock_point last_flush_start_time;

    /** Last flush end time. Updated just after fsync is finished.
    If smaller than start time, then flush operation is pending. */
    Log_clock_point last_flush_end_time;

    /** Flushing average time (in microseconds). */
    double flush_avg_time;

    /** Mutex which can be used to pause log flusher thread. */
    ib_mutex_t flusher_mutex;

    alignas(CACHE_LINE_SIZE)
    os_event_t flusher_event;
    /** Padding to avoid any dependency between the log flusher
    and the log writer threads. */
    alignas(CACHE_LINE_SIZE)

    ulint space_id; /*!< file space */

    /** Size of buffer used for the write-ahead (in bytes). */
    uint32_t write_ahead_buf_size;

    /** Aligned pointer to buffer used for the write-ahead. It is aligned to
    system page size (why?) and is currently limited by constant 64KB. */
    aligned_array_pointer<byte, 64 * 1024> write_ahead_buf;

    /** Up to this file offset in the log files, the write-ahead
    has been done or is not required (for any other reason). */
    uint64_t write_ahead_end_offset;
#endif /* !UNIV_HOTBACKUP */

    /** Some lsn value within the current log file. */
    lsn_t current_file_lsn;

    /** File offset for the current_file_lsn. */
    uint64_t current_file_real_offset;

    /** Up to this file offset we are within the same current log file. */
    uint64_t current_file_end_offset;
    /** Number of performed IO operations (only for printing stats). */
    ulint n_log_ios;

    /** Size of each single log file (expressed in bytes, including
    file header). */
    uint64_t file_size;

    /** Total capacity of all the log files (file_size * n_files),
    including headers of the log files. */
    uint64_t files_real_capacity;

#ifndef UNIV_HOTBACKUP
    /** Mutex which can be used to pause log writer thread. */
    ib_mutex_t writer_mutex;

    alignas(CACHE_LINE_SIZE)
    os_event_t writer_event;
    /** Padding after section for the log writer thread, to avoid any
    dependency between the log writer and the log closer threads. */
    alignas(CACHE_LINE_SIZE)

    /** Mutex which can be used to pause log closer thread. */
    ib_mutex_t closer_mutex;
    /** Padding after the log closer thread and before the memory used
    for communication between the log flusher and notifier threads. */
    alignas(CACHE_LINE_SIZE)

    /** Event used by the log flusher thread to notify the log flush
    notifier thread, that it should proceed with notifying user threads
    waiting for the advanced flushed_to_disk_lsn (because it has been
    advanced). */
    os_event_t flush_notifier_event;

    /** Mutex which can be used to pause log flush notifier thread. */
    ib_mutex_t flush_notifier_mutex;
    /** Padding. */
    alignas(CACHE_LINE_SIZE)
    /** Mutex which can be used to pause log write notifier thread. */
    ib_mutex_t write_notifier_mutex;

    alignas(CACHE_LINE_SIZE)
    /** Event used by the log writer thread to notify the log write
    notifier thread, that it should proceed with notifying user threads
    waiting for the advanced write_lsn (because it has been advanced). */
    os_event_t write_notifier_event;

    alignas(CACHE_LINE_SIZE)
    /** Used for stopping the log background threads. */
    std::atomic_bool should_stop_threads;
    /** True iff the log closer thread is alive. */
    std::atomic_bool closer_thread_alive;

    /** True iff the log checkpointer thread is alive. */
    std::atomic_bool checkpointer_thread_alive;

    /** True iff the log writer thread is alive. */
    std::atomic_bool writer_thread_alive;

    /** True iff the log flusher thread is alive. */
    std::atomic_bool flusher_thread_alive;

    /** True iff the log write notifier thread is alive. */
    std::atomic_bool write_notifier_thread_alive;

    /** True iff the log flush notifier thread is alive. */
    std::atomic_bool flush_notifier_thread_alive;

    /** Size of the log buffer expressed in number of data bytes,
    that is excluding bytes for headers and footers of log blocks. */
    atomic_sn_t buf_size_sn;

    /** Size of the log buffer expressed in number of total bytes,
    that is including bytes for headers and footers of log blocks. */
    size_t buf_size;

    /** Capacity of the log files available for log_free_check(). */
    lsn_t lsn_capacity_for_free_check;
#endif /* !UNIV_HOTBACKUP */

    /** Number of log files. */
    uint32_t n_files;

#ifndef UNIV_HOTBACKUP
    ulint state;        /*!< LOG_OK or LOG_CORRUPTED */

    /** Aligned buffers for file headers. */
    aligned_array_pointer<byte, OS_FILE_LOG_BLOCK_SIZE> *file_header_bufs;

    /** Number of total I/O operations performed when we printed
    the statistics last time. */
    ulint n_log_ios_old;

    /** Wall time when we printed the statistics last time. */
    time_t last_printout_time;

    /** Padding before memory used for checkpoints logic. */
    alignas(CACHE_LINE_SIZE)
    /** Event used by the log checkpointer thread to wait for requests. */
    os_event_t checkpointer_event;
    /** Mutex which can be used to pause log checkpointer thread. */
    ib_mutex_t checkpointer_mutex;

    /** Capacity of log files excluding headers of the log files.
    If the checkpoint age exceeds this, it is a serious error,
    because in such case we have already overwritten redo log. */
    lsn_t lsn_real_capacity;

    /** When the oldest dirty page age exceeds this value, we start
    an asynchronous preflush of dirty pages. */
    lsn_t max_modified_age_async;

    /** When the oldest dirty page age exceeds this value, we start
    a synchronous flush of dirty pages. */
    lsn_t max_modified_age_sync;

    /** When checkpoint age exceeds this value, we force writing next
    checkpoint (requesting the log checkpointer thread to do it). */
    lsn_t max_checkpoint_age_async;

    /** If should perform checkpoints every innodb_log_checkpoint_every ms.
    Disabled during startup / shutdown. */
    bool periodical_checkpoints_enabled;

    /** A new checkpoint could be written for this lsn value.
    Up to this lsn value, all dirty pages have been added to flush
    lists and flushed. Updated in the log checkpointer thread by
    taking?minimum oldest_modification out of the last dirty pages
    from each flush list. However it will not be bigger than the
    current value of log.buf_dirty_pages_added_up_to_lsn.
    Protected by: checkpointer_mutex.
    @see @ref subsect_redo_log_available_for_checkpoint_lsn */
    lsn_t available_for_checkpoint_lsn;

    /** When this is larger than the latest checkpoint, the log checkpointer
    thread will be forced to write a new checkpoint (unless the new latest
    checkpoint lsn would still be smaller than this value).
    Protected by: checkpointer_mutex. */
    lsn_t requested_checkpoint_lsn;

    /** Latest checkpoint wall time.
    Protected by: checkpointer_mutex. */
    Log_clock_point last_checkpoint_time;

    /** Latest checkpoint lsn.
    Protected by: checkpointer_mutex (writes).
    @see @ref subsect_redo_log_last_checkpoint_lsn */
    atomic_lsn_t last_checkpoint_lsn;
    /** Next checkpoint number.
    Protected by: checkpoint_mutex. */
    std::atomic<checkpoint_no_t> next_checkpoint_no;

    /** Aligned buffer used for writing a checkpoint header. It is aligned
    similarly to log.buf.
    Protected by: checkpointer_mutex. */
    aligned_array_pointer<byte, OS_FILE_LOG_BLOCK_SIZE> checkpoint_buf;
#endif /* !UNIV_HOTBACKUP */

 #ifdef UNIV_LOG_DEBUG
    ib_uint64_t old_lsn;    /*!< value of lsn when log was
                    last time opened; only in the
                    debug version */
#endif /* UNIV_LOG_DEBUG */

#ifndef UNIV_HOTBACKUP
    lsn_t next_checkpoint_lsn;
                    /*!< next checkpoint lsn */
#endif /* !UNIV_HOTBACKUP */
};
                            
```