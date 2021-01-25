#1.class Transaction_ctx

```cpp
class Transaction_ctx
{
public:
  enum enum_trx_scope { STMT= 0, SESSION };

  SAVEPOINT *m_savepoints;
private:
  THD_TRANS m_scope_info[2];

  XID_STATE m_xid_state;

  /*
    Tables changed in transaction (that must be invalidated in query cache).
    List contain only transactional tables, that not invalidated in query
    cache (instead of full list of changed in transaction tables).
  */
  CHANGED_TABLE_LIST* m_changed_tables;
  MEM_ROOT m_mem_root; // Transaction-life memory allocation pool
  
public:
  /*
    (Mostly) binlog-specific fields use while flushing the caches
    and committing transactions.
    We don't use bitfield any more in the struct. Modification will
    be lost when concurrently updating multiple bit fields. It will
    cause a race condition in a multi-threaded application. And we
    already caught a race condition case between xid_written and
    ready_preempt in MYSQL_BIN_LOG::ordered_commit.
  */
  struct
  {
    bool enabled;                   // see ha_enable_transaction()
    bool pending;                   // Is the transaction commit pending?
    bool xid_written;               // The session wrote an XID
    bool real_commit;               // Is this a "real" commit?
    bool commit_low;                // see MYSQL_BIN_LOG::ordered_commit
    bool run_hooks;                 // Call the after_commit hook
#ifndef DBUG_OFF
    bool ready_preempt;             // internal in MYSQL_BIN_LOG::ordered_commit
#endif
  } m_flags;
  /* Binlog-specific logical timestamps. */
  /*
    Store for the transaction's commit parent sequence_number.
    The value specifies this transaction dependency with a "parent"
    transaction.
    The member is assigned, when the transaction is about to commit
    in binlog to a value of the last committed transaction's sequence_number.
    This and last_committed as numbers are kept ever incremented
    regardless of binary logs being rotated or when transaction
    is logged in multiple pieces.
    However the logger to the binary log may convert them
    according to its specification.
  */
  int64 last_committed;
  /*
    The transaction's private logical timestamp assigned at the
    transaction prepare phase. The timestamp enumerates transactions
    in the binary log. The value is gained through incrementing (stepping) a
    global clock.
    Eventually the value is considered to increase max_committed_transaction
    system clock when the transaction has committed.
  */
  int64 sequence_number;    

...
...

private:
  Rpl_transaction_ctx m_rpl_transaction_ctx;
  Rpl_transaction_write_set_ctx m_transaction_write_set_ctx;
};  
```

#2.struct THD_TRANS

```cpp
  struct THD_TRANS
  {
    /* true is not all entries in the ht[] support 2pc */
    bool        m_no_2pc;
    int         m_rw_ha_count;
    /* storage engines that registered in this transaction */
    Ha_trx_info *m_ha_list;

  private:
    /*
      The purpose of this member variable (i.e. flag) is to keep track of
      statements which cannot be rolled back safely(completely).
      For example,

      * statements that modified non-transactional tables. The value
      MODIFIED_NON_TRANS_TABLE is set within mysql_insert, mysql_update,
      mysql_delete, etc if a non-transactional table is modified.

      * 'DROP TEMPORARY TABLE' and 'CREATE TEMPORARY TABLE' statements.
      The former sets the value DROPPED_TEMP_TABLE and the latter
      the value CREATED_TEMP_TABLE.

      The tracked statements are modified in scope of:

      * transaction, when the variable is a member of
      THD::m_transaction.m_scope_info[SESSION]

      * top-level statement or sub-statement, when the variable is a
      member of THD::m_transaction.m_scope_info[STMT]

      This member has the following life cycle:

      * m_scope_info[STMT].m_unsafe_rollback_flags is used to keep track of
      top-level statements which cannot be rolled back safely. At the end of the
      statement, the value of m_scope_info[STMT].m_unsafe_rollback_flags is
      merged with m_scope_info[SESSION].m_unsafe_rollback_flags
      and gets reset.

      * m_scope_info[SESSION].cannot_safely_rollback is reset at the end
      of transaction

      * Since we do not have a dedicated context for execution of
      a sub-statement, to keep track of non-transactional changes in a
      sub-statement, we re-use m_scope_info[STMT].m_unsafe_rollback_flags.
      At entrance into a sub-statement, a copy of the value of
      m_scope_info[STMT].m_unsafe_rollback_flags (containing the changes of the
      outer statement) is saved on stack.
      Then m_scope_info[STMT].m_unsafe_rollback_flags is reset to 0 and the
      substatement is executed. Then the new value is merged
      with the saved value.
    */

    unsigned int m_unsafe_rollback_flags;
    /*
      Define the type of statements which cannot be rolled back safely.
      Each type occupies one bit in m_unsafe_rollback_flags.
    */
    static unsigned int const MODIFIED_NON_TRANS_TABLE= 0x01;
    static unsigned int const CREATED_TEMP_TABLE= 0x02;
    static unsigned int const DROPPED_TEMP_TABLE= 0x04;
  };    
```

#3.