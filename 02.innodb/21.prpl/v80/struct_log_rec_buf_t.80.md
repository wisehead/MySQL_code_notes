#1.struct log_rec_buf_t

```cpp
/* Log record buffer
 * Buffer to store log records.
 * Secondary: Consists of multiple log blocks (but with
 * header & trailed stripped off). After receives a log block, the log
 * fetcher strips off its header & trailer and copy it into this buffer.
 * Log shredder will shred the blocks into log records to be applied later.
 * The buffer will be freed after all log records are applied, i.e. when log
 * apply lwm passes the last log record in the buffer.
 * PageServer: Consists of log records without block structs.
 * The log fetcher pull logs from log service and store here.
 * The log coordinate parse the logs and send them to log apply queue.
 *  */
struct log_rec_buf_t {
  /* How many block body this buffer could store */
  ulint     buf_size;
  ulint     buf_no;
  /* End lsn of log records in this buffer.
   * This buffer is recycled when lwm passes it. */
  atomic_lsn_t     end_lsn;
  /* Write: next filling write from here.
   * Read:  log shredder could shred log behind the offset. */
  atomic_ulint_t  fill_end;
  /* shred log end offset, start offset of next shredding */
  ulint     shred_end;
  /* Status: Log Fetcher / Log Shredder */
  atomic_bool_t   filled_full;
  atomic_bool_t   shredded_all;
  /* Memory */
  byte      *data;
  /* Innodb List Style */
  UT_LIST_NODE_T(log_rec_buf_t) rec_buf_list;

  /* FUNCTIONS */
  /* Init a record buffer */
  log_rec_buf_t() {}
  log_rec_buf_t(size_t size, ulint no) {
    buf_size = size;
    buf_no = no;
    data = (byte *)malloc(buf_size);
    fill_end.store(0);
    end_lsn.store(UINT64_MAX);
    shred_end = 0;
    filled_full.store(FALSE);
    shredded_all.store(FALSE);
  }

  ~log_rec_buf_t() {
    free(data);
  }

  void fill_init(lsn_t start_lsn);

  /* PageServer: Add log records to log_rec_buf_t
   * NOTE: the free space in log_rec_buf_t should enough for records
   @param[in] records: addr of log records responded by log service
   @param[in] total_len: length of all records */
  void add_log_records(byte * records, ulint total_len);

  /* shred and the dispatch log records from current log_rec_buf_t */
  ulint shred_and_dispatch_log_rec(lsn_t &rec_start_lsn);
};  
```