#1.struct page_cleaner_slot_t

```cpp
/** Page cleaner request state for each buffer pool instance */
struct page_cleaner_slot_t {
  page_cleaner_state_t state; /*!< state of the request.
                              protected by page_cleaner_t::mutex
                              if the worker thread got the slot and
                              set to PAGE_CLEANER_STATE_FLUSHING,
                              n_flushed_lru and n_flushed_list can be
                              updated only by the worker thread */
  /* This value is set during state==PAGE_CLEANER_STATE_NONE */
  ulint n_pages_requested;
  /*!< number of requested pages
  for the slot */
  /* These values are updated during state==PAGE_CLEANER_STATE_FLUSHING,
  and commited with state==PAGE_CLEANER_STATE_FINISHED.
  The consistency is protected by the 'state' */
  ulint n_flushed_lru;
  /*!< number of flushed pages
  by LRU scan flushing */
  ulint n_flushed_list;
  /*!< number of flushed pages
  by flush_list flushing */
  bool succeeded_list;
  /*!< true if flush_list flushing
  succeeded. */
  uint64_t flush_lru_time;
  /*!< elapsed time for LRU flushing */
  uint64_t flush_list_time;
  /*!< elapsed time for flush_list
  flushing */
  ulint flush_lru_pass;
  /*!< count to attempt LRU flushing */
  ulint flush_list_pass;
  /*!< count to attempt flush_list
  flushing */
};
```