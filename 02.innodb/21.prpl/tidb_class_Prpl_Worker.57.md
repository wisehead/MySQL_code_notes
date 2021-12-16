#1.	class Prpl_Worker

```cpp
/** Control structure of log apply coordinator thread.
Basically we have N worker threads and one coordinator thread,
the coordinator thread will distribute redo log in round-robin
fashion to make sure every worker's workload balancedlog, the
worker thread does the real applying job. */
class Prpl_Worker {
public:
  /* Default constructor */
  Prpl_Worker(uint32_t id);

  /* Deconstructor */
  ~Prpl_Worker();

  /* Log worker id */
  uint32_t id() const { return m_id; }

  /** Thread should abort. */
  void set_abort() { m_abort = true; }

  /** Entry of log apply worker thread. */
  void run();

  /** Log apply coordinator there's jobs. */
  inline void notify() { os_event_set(m_task); }

  /** When log coordinator takes out a log group from @m_log_groups
  and of course the log group is already prepared for applying, then
  distribute redo records to all log workers in round-robin fashion
  by invoking this function.
  @param slot  the head of record chain belongs to one page. */
  inline void add_redo(prpl_slot_t* slot);

  /** Apply redo records belong to me for a log group */
  void apply();

  /** Log scanner has already parsed a log group, this function
  applys all the records belongs to one page in the hash table
  @param[in] slot  head of chained records belongs to one page.
  @return  false if failed to acquire block lock, otherwise true */
  bool apply_redo_to_one_slot(prpl_slot_t* slot);

  /** Low implemention of apply_redo_to_one_slot()
  @param[in] slot   head of chained records belong to one page
  @param[in] block  block != NULL, apply the redo logs, or just
                    update statistics. */
  void apply_redo_to_one_slot_low(prpl_slot_t* slot,
      buf_block_t* block);

  /** The buffer block isn't in buffer pool, skip the redo reocrds.
  @param[in] slot  head of chained records belongs to one page. */
  void skip_redo_to_one_slot_low(prpl_slot_t* slot);

private:
  /** Log worker id */
  uint32_t m_id;

  /** THD object */
  THD* m_thd;

  /** Notify apply workers there's task. */
  os_event_t m_task;

  /** True if thread should exist */
  std::atomic<bool> m_abort;

  /** Log coordinator dist redo records by round-robin
  to each worker's private record list. Each slot links
  all redo records to one page in a log group */
  UT_LIST_BASE_NODE_T(prpl_slot_t) m_slots;
};  

```