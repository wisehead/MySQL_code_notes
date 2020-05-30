#1.log_rec_buf_mgr_t

```cpp
/* Log record buffer manager
 * Log Fetcher/Shredder/Monitor may touch the same buffer at the same time.
 * This struct is used for simplifying the shared buffer logic.
 * manage the log rec buffers in two list: free && used.
 * log fetcher (as a producer) add blocks to the last buffer in used list until
 * it has no free space left. log shredder (as a consumer) shred the buffer
 * from head in used list one by one and log monitor recycle the buffer as the
 * same order.
 template: buffer, log_rec_buf_t or pool */
struct log_rec_buf_mgr_t {
  /* proctect the list */
  ib_mutex_t  prpl_rec_buf_mgr_mutex;
  /* component List */
  UT_LIST_BASE_NODE_T(log_rec_buf_t) free_list;
  UT_LIST_BASE_NODE_T(log_rec_buf_t) used_list;

  /* first rec buf recycle lsn in used list
   * protected by prpl_rec_buf_mgr_mutex */
  //atomic_lsn_t  recycle_lsn;
  /* current using buffer for shredder and fetcher */
  log_rec_buf_t *cur_fetch_buf, *cur_shred_buf;

  /* constructor */
  log_rec_buf_mgr_t(size_t buf_size, size_t num_buf) {
    mutex_create(LATCH_ID_PRPL_BUF_MGR, &prpl_rec_buf_mgr_mutex);
    //recycle_lsn.store(UINT64_MAX);
    cur_fetch_buf = nullptr;
    cur_shred_buf = nullptr;

    mutex_enter(&prpl_rec_buf_mgr_mutex);

    UT_LIST_INIT(free_list, &log_rec_buf_t::rec_buf_list);
    UT_LIST_INIT(used_list, &log_rec_buf_t::rec_buf_list);

    /* Init buffers */
    for (size_t i = 0; i < num_buf; i++) {
      UT_LIST_ADD_LAST(free_list, new log_rec_buf_t(buf_size, i));
    }

    mutex_exit(&prpl_rec_buf_mgr_mutex);
  }

  ~log_rec_buf_mgr_t() {
    mutex_free(&prpl_rec_buf_mgr_mutex);
    log_rec_buf_t * it = NULL;
    while ((it = UT_LIST_GET_FIRST(free_list))) {
      UT_LIST_REMOVE(free_list, it);
      delete it;
    }
    while ((it = UT_LIST_GET_FIRST(used_list))) {
      UT_LIST_REMOVE(used_list, it);
      delete it;
    }
  }
  /* Return the record buffer to store log records */
  log_rec_buf_t *get_rec_buf_for_fetcher(lsn_t fetch_lsn);

  /* Return the record buffer where parse and dispatch log records from
  to apply queues */
  log_rec_buf_t *get_rec_buf_for_shredder();

  /* Recycle the record buffer in used list which have been applied
   * completely recycle from the first one, remove it from used list
   * to free list.
   @param[in] lwm: prpl system have applied lsn */
  void recycle_buf(lsn_t lwm);
};  
```