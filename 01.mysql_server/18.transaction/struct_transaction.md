#1.transaction

```cpp
  struct st_transactions {
    SAVEPOINT *savepoints;
    THD_TRANS all;          // Trans since BEGIN WORK
    THD_TRANS stmt;         // Trans for current statement
    XID_STATE xid_state;
    Rows_log_event *m_pending_rows_event;

    /*
       Tables changed in transaction (that must be invalidated in query cache).
       List contain only transactional tables, that not invalidated in query
       cache (instead of full list of changed in transaction tables).
    */
    CHANGED_TABLE_LIST* changed_tables;
    MEM_ROOT mem_root; // Transaction-life memory allocation pool

    /*
      (Mostly) binlog-specific fields use while flushing the caches
      and committing transactions.
      We don't use bitfield any more in the struct. Modification will
      be lost when concurrently updating multiple bit fields. It will
      cause a race condition in a multi-threaded application. And we
      already caught a race condition case between xid_written and
      ready_preempt in MYSQL_BIN_LOG::ordered_commit.
    */
    struct {
      bool enabled;                   // see ha_enable_transaction()
      bool pending;                   // Is the transaction commit pending?
      bool xid_written;               // The session wrote an XID
      bool real_commit;               // Is this a "real" commit?
      bool commit_low;                // see MYSQL_BIN_LOG::ordered_commit
      bool run_hooks;                 // Call the after_commit hook
#ifndef DBUG_OFF
      bool ready_preempt;             // internal in MYSQL_BIN_LOG::ordered_commit
#endif
    } flags;
  } transaction;    
```

#2. THD_TRANS

```cpp
struct THD_TRANS
{
  /* true is not all entries in the ht[] support 2pc */
  bool        no_2pc;
  int         rw_ha_count;
  /* storage engines that registered in this transaction */
  Ha_trx_info *ha_list;
};  
```