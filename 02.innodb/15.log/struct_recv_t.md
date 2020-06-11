#1.struct recv_t

```cpp
/** Stored log record struct */
struct recv_t {
  using Node = UT_LIST_NODE_T(recv_t);

  /** Log record type */
  mlog_id_t type;

  /** Log record body length in bytes */
  ulint len;

  /** Chain of blocks containing the log record body */
  recv_data_t *data;

  /** Start lsn of the log segment written by the mtr which generated
  this log record: NOTE that this is not necessarily the start lsn of
  this log record */
  lsn_t start_lsn;

  /** End lsn of the log segment written by the mtr which generated
  this log record: NOTE that this is not necessarily the end LSN of
  this log record */
  lsn_t end_lsn;

  /** List node, list anchored in recv_addr_t */
  Node rec_list;
};
```

#2.struct recv_data_t 

```cpp
/** Block of log record data */
struct recv_data_t {
  /** pointer to the next block or NULL.  The log record data
  is stored physically immediately after this struct, max amount
  RECV_DATA_BLOCK_SIZE bytes of it */

  recv_data_t *next;
};

```