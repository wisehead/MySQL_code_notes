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

#3.Ha_trx_info

```cpp
/**
  Either statement transaction or normal transaction - related
  thread-specific storage engine data.

  If a storage engine participates in a statement/transaction,
  an instance of this class is present in
  thd->transaction.{stmt|all}.ha_list. The addition to
  {stmt|all}.ha_list is made by trans_register_ha().

  When it's time to commit or rollback, each element of ha_list
  is used to access storage engine's prepare()/commit()/rollback()
  methods, and also to evaluate if a full two phase commit is
  necessary.

  @sa General description of transaction handling in handler.cc.
*/

class Ha_trx_info
{
private:
  enum { TRX_READ_ONLY= 0, TRX_READ_WRITE= 1 };
  /** Auxiliary, used for ha_list management */
  Ha_trx_info *m_next;
  /**
    Although a given Ha_trx_info instance is currently always used
    for the same storage engine, 'ht' is not-NULL only when the
    corresponding storage is a part of a transaction.
  */
  handlerton *m_ht;
  /**
    Transaction flags related to this engine.
    Not-null only if this instance is a part of transaction.
    May assume a combination of enum values above.
  */
  uchar       m_flags;
};
```