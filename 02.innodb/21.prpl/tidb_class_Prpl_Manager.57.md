#1.class Prpl_Manager


```cpp

/** Control structure of log apply coordinator thread. */
class Prpl_Manager {
public:

  /** On high level design. parallel replication split log stream
  into chunks, each chunk is called a Log Group, in other words,
  log group is a series of redo records. And log scanner thread
  parses the group of log records into a hash table for log apply
  coordinator/workers to replay. */
  struct Log_Group {
    /** Default constructor */
    Log_Group() {
      m_spaces = UT_NEW_NOKEY(Spaces());
      m_capacity = PRPL_LOG_GROUP_CAPACITY;

      /* In genereal, the first mem_block_t is big enough
      for one log group's redo record structure, rarely need
      invoking malloc(). */
      m_heap = mem_heap_create(PRPL_LOG_GROUP_HEAP_SIZE);
      m_spaces->clear();

      m_id = 0;
      m_end_lsn = 0;
      m_barrier = BARRIER_NONE;
      m_state = INIT_FINISHED;
      m_buffer = static_cast<byte*>(
          ut_malloc_nokey(m_capacity));

      m_mtrs  = Count_buf<lsn_t>{m_capacity};
      m_pages = Count_buf<lsn_t>{m_capacity / 32};

      UT_LIST_INIT(m_pre_recs, &rpl_rec_t::rec_list);
      UT_LIST_INIT(m_post_recs, &rpl_rec_t::rec_list);
    }
   /* Destructor */
    ~Log_Group() {
      ut_ad(m_spaces != NULL);
      UT_DELETE(m_spaces);
      m_spaces = NULL;

      ut_free(m_buffer);

      mem_heap_free(m_heap);
    }

    /* Type only used in swap_hash() */
    enum Type {
      TYPE_PARSE = 0, /* For log scanner thread */
      TYPE_APPLY = 1  /* For log coordinator thread */
    };

    /* Log group state: inited -> parsed -> applied */
    enum State {
      INIT_FINISHED  = 0,
      PARSE_FINISHED = 1,
      APPLY_FINISHED = 2,
    };

    /* Log barrier type; For now: rtree or else */
    enum Barrier {
      BARRIER_NONE  = 0,
      BARRIER_RTREE = 1,
      BARRIER_ELSE  = 2,
      BARRIER_BIGGEST
    };

    /* Copy redo records to my private buffer
    @param[in] log_buffer  redo log buffer
    @param[in] len  log buffer length */
    inline void copy_buffer(byte* log_buffer, ulint len) {
      memcpy(m_buffer, log_buffer, len);
    }

    /* Validate there's no barrier until now */
    inline void valid_barrier() {
      ut_ad(m_barrier == BARRIER_NONE);
    }

    /** Empty hash table after log records have all been applied */
    inline void empty_hash() {
      ut_ad(m_state == APPLY_FINISHED);

      UT_DELETE(m_spaces);
      m_spaces = UT_NEW_NOKEY(Spaces());
      m_spaces->clear();

      mem_heap_empty(m_heap);

      /** IMPORTANT: No need to clear m_buffer, just override
      old contents. And experiment shows that invoking mem_set
      will critical hurt log applying performance! */

      m_end_lsn = 0;
      m_barrier = BARRIER_NONE;

      ut_ad(!UT_LIST_GET_LEN(m_pre_recs));
      ut_ad(!UT_LIST_GET_LEN(m_post_recs));

      m_state = INIT_FINISHED;
    }

    using Pages =
      std::unordered_map<ulint, prpl_slot_t *, std::hash<ulint>,
                           std::equal_to<ulint>>;

    /** Every space has its a heap and pages that belong to it. */
    struct Space {
        /** Constructor
      @param[in,out]  heap  Heap to use for the log records. */
      explicit Space(mem_heap_t *heap) : m_heap(heap), m_pages() {}

      /** Default constructor */
      Space() : m_heap(), m_pages() {}

      /** Memory heap of log records and file addresses */
      mem_heap_t *m_heap;

      /** Pages that need to be recovered */
      Pages m_pages;
    };

    using Spaces = std::unordered_map<ulint, Space, std::hash<ulint>,
                                      std::equal_to<ulint>>;

    /** Hash table of redo records. The purpose is to link redo
    records belong to one page together, then log worker can only
    acquire latch once for each page within a log group */
    Spaces* m_spaces;

    /** Memory heap of log records control data structures. */
    mem_heap_t *m_heap;

    /* Log group state. */
    State m_state;

    /** Log barrier type, there can only one barrier in each log group */
    Barrier m_barrier;

    /* Atomic array for tracking mtr complete status within a log group. */
    Count_buf<lsn_t> m_mtrs;

    /* Atomic array for tracking page complete status within a log group. */
    Count_buf<ulint> m_pages;

    /** Every log group has its own buffer for log record bodys. */
    byte* m_buffer;

    /** Capacity of log group. It's the size of @m_buffer */
    ulint m_capacity;

    /** Log group identifier; This is a simple ascending sequence
    with no gaps, thus it represents the number of log groups since
    database started. */
    ulint m_id;

    /** The maximum redo record end lsn within this log group. */
    lsn_t m_end_lsn;

    /** The redo records should be applied before applying hash table. */
    UT_LIST_BASE_NODE_T(rpl_rec_t) m_pre_recs;

    /** The redo records should be applied after applying hash table. */
    UT_LIST_BASE_NODE_T(rpl_rec_t) m_post_recs;
  };

  /** Default constructor */
  Prpl_Manager();

  /** Deconstructor */
  ~Prpl_Manager();


  /** Increment active log worker number */
  void inc_active_worker() { m_active_workers ++; }

  /** Decrement active log worker number */
  void dec_active_worker() { m_active_workers --; }

  /** Return log group id that is parsing */
  uint64_t curr_parsing_id() const { return m_parsing_id.load(); }

  /** Return log group id that is applying */
  uint64_t curr_applying_id() const { return m_applying_id.load(); }

  /** Increment log group id which should be parsed next */
  inline void advance_parsing_id() { m_parsing_id.fetch_add(1); }

  /** Increment log group id which should be applied next */
  inline void advance_applying_id() { m_applying_id.fetch_add(1); }

  /** Abort log coordinator thread */
  void set_abort() { m_abort = true; }

  /** Increment redo records be applied by log workers */
  void inc_curr_recs() { m_curr_recs.fetch_add(1); }

  /** Decrement redo records be applied by log workers */
  void dec_curr_recs() { m_curr_recs.fetch_sub(1); }

  /** Start log apply coordinator/worker threads */
  void start_background_threads();

  /** Stop log apply coordinator/worker threads */
  void stop_background_threads();

  /** Distribute redo records to a hash table of log group
  @param[in] buf_ptr  redo buffer
  @param[in] buf_len  redo records length
  @return  False if everything goes well. */
  bool dist_log_recs(byte* buf_ptr, ulint buf_len);

  /* Low level implemention of dist_log_recs()
  @param[in] buf_ptr  redo buffer
  @param[in] buf_len  redo records length
  @return  False if everything goes well. */
  bool dist_log_recs_low(byte* buf_ptr, ulint buf_len);

  /** Parse one redo record, decide its destination, to post list
  or hash table
  @param[in] ptr  pointer to a log record
  @param[in] multi_page  true if it belongs to a multi page mtr
  @param[in] mtr_end_lsn  the mtr's end lsn which it belongs */
  void parse_one_rec(byte* ptr, bool multi_page, lsn_t mtr_end_lsn);

  /** Add one redo record to log group's hash table
  @param[in] ptr  pointer to a log record
  @param[in] multi_page  true if it belongs to a multi page mtr
  @param[in] mtr_end_lsn  the mtr's end lsn which it belongs */
  void add_to_hash_table(byte* ptr, bool multi_page, lsn_t mtr_end_lsn);

  /** Add one redo record to log group's post record list
  @param[in] ptr  pointer to a log record */
  void add_to_post_list(byte* ptr);
  /** We allow concurrent parsing while applying redo log, so here
  we use a list of hash tables to form a ring array, and log scanner
  is the producer, log coordinator is the consumer.
  Invoke this function if the following consition happens:
  1. Log scanner thread will parse new log group, prepare next hash
     table for the incoming log group records.
  2. Log coordinator thread has applied a log group, prepare next
     hash table (must already been parsed) to apply.
  @param[in] type  TYPE_PARSE for log scanner thread or TYPE_APPLY
     for log coordinator thread */
  void swap_hash(const Log_Group::Type type);

  /** Entry of log apply coordinator thread */
  void run();

  /** Reduce task counter once a worker thread finishes its
  job and wakeup log-coordinator thread once it decreases
  to zero */
  void task_done();

  /** First, The hash table links redo records belong to one page
  together. Then log coordinator distribute redo records by round
  robin method to each worker's private record list. In order to
  make log records well-distributed through all log apply workers */
  void prepare();

  /** Main routine of apply hashed logs. the log-coordinator
  thread invokes this function to wakeup all worker threads,
  which does real apply job */
  void apply();

  /** Log coordinator apply redo records belong to post list */
  void apply_post_recs();

  /** Pick log worker for one redo record.
  @param[in] space_id  space id of buffer block
  @param[in] page_no  page no of buffer block */
  Prpl_Worker* pick_worker(ulint space_id, ulint page_no);

  /** Calaulate log parse/apply speed (MB/s).
  @param[in] lsn_diff  lsn difference
  @param[in] ts_diff   timestamp difference (microsecond) */
  ulint log_group_calc_rate(lsn_t lsn_diff, uint64_t ts_diff);

  /** Invoked by log scanner thread, indicates there's
  one more page belongs to this log group.
  @param[in] fold  the fold value */
  void log_group_page_inc(const ulint fold);

  /** Invoked by log apply worker thread, indicates there's
  one more page belongs to this log group has been applied.
  @param[in] fild  the fold value */
  void log_group_page_dec(const ulint fold);

  /** Check if the page with spacified fold value has been applied
  NOTE: The return value maybe imprecise!
  @param[in] fold  the fold value.
  @return true if spceified page's log have all been applied. */
  bool log_group_page_complete(const ulint fold);

  /** Invoked by log scanner thread, indicates there's one more
  record belongs to a mini-transaction ends with @mtr_end_lsn
  prepares to be applied.
  @param[in] mtr_end_lsn mtr's end lsn */
  void log_group_mtr_inc(const lsn_t mtr_end_lsn);


  /** Invoked by log apply worker thread, indicates there's one
  more record belongs to a mini-transaction ends with @mtr_end_lsn
  that has been applied
  @param[in] mtr_end_lsn mtr's end lsn */
  void log_group_mtr_dec(const lsn_t mtr_end_lsn);

  /** Debug check if a mini-transaction is not multi-page
  @param[in] mtr_end_lsn mtr's end lsn */
  bool log_group_mtr_single(const lsn_t mtr_end_lsn);

  /** Check if the mini-transaction ends with @mtr_end_lsn has been applied
  completed within a log group. Invoked by reader mostly in two scenarios:
  1- If a buffer block has split or merge operation within a log group. that's
     to say: block smo mtr lsn > applied lsn. If so, repeatedly invoking this
     function until return value is true (smo is completed)
  2- Whether the undo page reuse is happened whithin a log group. If so, then
     the reader repeatedly invoking this function until return value is true
     (the undo reuse mtr is completed)
  @param[in] mtr_end_lsn mtr's end lsn
  @return the specified mtr is completed */
  bool log_group_mtr_complete(const lsn_t mtr_end_lsn);

private:

  /* Number of log groups */
  ulint m_n_log_group;

  /* Log group circular array. */
  Log_Group** m_log_groups;

  /** Padding for the frequently updated variables */

  /* Log group instance that log scanner is parsing now */
  alignas(INNOBASE_CACHE_LINE_SIZE)
  Log_Group* m_parsing_group;

  /* Log group instance that log apply workers are applying now */
  alignas(INNOBASE_CACHE_LINE_SIZE)
  Log_Group* m_applying_group;

  /* The id of log group that log scanner is parsing */
  alignas(INNOBASE_CACHE_LINE_SIZE)
  std::atomic<uint64_t> m_parsing_id;

  /* The id of log group that log workers are applying */
  alignas(INNOBASE_CACHE_LINE_SIZE)
  std::atomic<uint64_t> m_applying_id;

  /** Number of incompleted tasks log coordinator has assigned */
  alignas(INNOBASE_CACHE_LINE_SIZE)
  std::atomic<uint32_t> m_n_tasks;

  /** True if log coordinator thread is active */
  std::atomic<bool> m_active;

  /** True if log coordinator thread should exist */
  std::atomic<bool> m_abort;

  /* THD object */
  THD* m_thd;

  /** Number of log apply workers, must be greater than 1 */
  ulint m_n_workers;

  /** Number of records have been prepared for apply. */
  std::atomic<ulint> m_curr_recs;
  
  /* Event to tell log-coordinator that job has been done */
  os_event_t m_done;

  /* Event to tell log-scanner there's free space in log group array */
  os_event_t m_parse;

  /* Event to tell log-coordinator there's new job */
  os_event_t m_apply;

  /** Number of active log workers */
  std::atomic<uint32_t> m_active_workers;

  /** Log apply workers array */
  Prpl_Worker** m_workers;
};
                
```
