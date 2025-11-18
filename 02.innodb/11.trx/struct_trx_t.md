#1.struct trx_t

```cpp
/** The transaction handle

Normally, there is a 1:1 relationship between a transaction handle
(trx) and a session (client connection). One session is associated
with exactly one user transaction. There are some exceptions to this:

* For DDL operations, a subtransaction is allocated that modifies the
data dictionary tables. Lock waits and deadlocks are prevented by
acquiring the dict_operation_lock before starting the subtransaction
and releasing it after committing the subtransaction.

* The purge system uses a special transaction that is not associated
with any session.

* If the system crashed or it was quickly shut down while there were
transactions in the ACTIVE or PREPARED state, these transactions would
no longer be associated with a session when the server is restarted.

A session may be served by at most one thread at a time. The serving
thread of a session might change in some MySQL implementations.
Therefore we do not have os_thread_get_curr_id() assertions in the code.

Normally, only the thread that is currently associated with a running
transaction may access (read and modify) the trx object, and it may do
so without holding any mutex. The following are exceptions to this:

* trx_rollback_resurrected() may access resurrected (connectionless)
transactions while the system is already processing new user
transactions. The trx_sys->mutex prevents a race condition between it
and lock_trx_release_locks() [invoked by trx_commit()].

* trx_print_low() may access transactions not associated with the current
thread. The caller must be holding trx_sys->mutex and lock_sys->mutex.

* When a transaction handle is in the trx_sys->mysql_trx_list or
trx_sys->trx_list, some of its fields must not be modified without
holding trx_sys->mutex exclusively.

* The locking code (in particular, lock_deadlock_recursive() and
lock_rec_convert_impl_to_expl()) will access transactions associated
to other connections. The locks of transactions are protected by
lock_sys->mutex and sometimes by trx->mutex. */
struct trx_t{
    UT_LIST_NODE_T(trx_t)
            trx_list;             /*!< list of transactions;
                                  protected by trx_sys->mutex.*/
    UT_LIST_NODE_T(trx_t)
            no_list;               /*!< Required during view creation
                                   to check for the view limit for
                                   transactions that are committing */

    trx_id_t        id;           /*!< transaction id */

    trx_id_t        no;           /*!< transaction serialization number:
                    max trx id shortly before the
                    transaction is moved to
                    COMMITTED_IN_MEMORY state.
                    Protected by trx_sys_t::mutex
                    when trx->in_rw_trx_list. Initially
                    set to TRX_ID_MAX. */
    /** State of the trx from the point of view of concurrency control
    and the valid state transitions.

    Possible states:

    TRX_STATE_NOT_STARTED
    TRX_STATE_ACTIVE
    TRX_STATE_PREPARED
    TRX_STATE_COMMITTED_IN_MEMORY (alias below COMMITTED)

    Valid state transitions are:

    Regular transactions:
    * NOT_STARTED -> ACTIVE -> COMMITTED -> NOT_STARTED

    Auto-commit non-locking read-only:
    * NOT_STARTED -> ACTIVE -> NOT_STARTED

    XA (2PC):
    * NOT_STARTED -> ACTIVE -> PREPARED -> COMMITTED -> NOT_STARTED

    Recovered XA:
    * NOT_STARTED -> PREPARED -> COMMITTED -> (freed)

    XA (2PC) (shutdown before ROLLBACK or COMMIT):
    * NOT_STARTED -> PREPARED -> (freed)

    Latching and various transaction lists membership rules:

    XA (2PC) transactions are always treated as non-autocommit.

    Transitions to ACTIVE or NOT_STARTED occur when
    !in_rw_trx_list (no trx_sys->mutex needed).

    Autocommit non-locking read-only transactions move between states
    without holding any mutex. They are !in_rw_trx_list.

    All transactions, unless they are determined to be ac-nl-ro,
    explicitly tagged as read-only or read-write, will first be put
    on the read-only transaction list. Only when a !read-only transaction
    in the read-only list tries to acquire an X or IX lock on a table
    do we remove it from the read-only list and put it on the read-write
    list. During this switch we assign it a rollback segment.

    When a transaction is NOT_STARTED, it can be in_mysql_trx_list if
    it is a user transaction. It cannot be in rw_trx_list.

    ACTIVE->PREPARED->COMMITTED is only possible when trx->in_rw_trx_list.
    The transition ACTIVE->PREPARED is protected by trx_sys->mutex.

    ACTIVE->COMMITTED is possible when the transaction is in
    rw_trx_list.

    Transitions to COMMITTED are protected by both lock_sys->mutex
    and trx->mutex.

    NOTE: Some of these state change constraints are an overkill,
    currently only required for a consistent view for printing stats.
    This unnecessarily adds a huge cost for the general case. */

    trx_state_t     state;

    ib_mutex_t  mutex;      /*!< Mutex protecting the fields
                    state and lock
                    (except some fields of lock, which
                    are protected by lock_sys->mutex) */

    trx_lock_t  lock;       /*!< Information about the transaction
                    locks and state. Protected by
                    trx->mutex or lock_sys->mutex
                    or both */
    bool        is_recovered;   /*!< 0=normal transaction,
                    1=recovered, must be rolled back,
                    protected by trx_sys->mutex when
                    trx->in_rw_trx_list holds */

    /* These fields are not protected by any mutex. */
    const char* op_info;    /*!< English text describing the
                    current operation, or an empty
                    string */
    ulint       isolation_level;/*!< TRX_ISO_REPEATABLE_READ, ... */
    bool        check_foreigns; /*!< normally TRUE, but if the user
                    wants to suppress foreign key checks,
                    (in table imports, for example) we
                    set this FALSE */
    /*------------------------------*/
    /* MySQL has a transaction coordinator to coordinate two phase
    commit between multiple storage engines and the binary log. When
    an engine participates in a transaction, it's responsible for
    registering itself using the trans_register_ha() API. */
    unsigned    is_registered:1;/* This flag is set to 1 after the
                    transaction has been registered with
                    the coordinator using the XA API, and
                    is set to 0 after commit or rollback. */
    unsigned    owns_prepare_mutex:1;/* 1 if owns prepare mutex, if
                    this is set to 1 then registered should
                    also be set to 1. This is used in the
                    XA code */

    /*------------------------------*/
    bool        check_unique_secondary;
                    /*!< normally TRUE, but if the user
                    wants to speed up inserts by
                    suppressing unique key checks
                    for secondary indexes when we decide
                    if we can use the insert buffer for
                    them, we set this FALSE */
    bool        support_xa; /*!< normally we do the XA two-phase
                    commit steps, but by setting this to
                    FALSE, one can save CPU time and about
                    150 bytes in the undo log size as then
                    we skip XA steps */
    bool        flush_log_later;/* In 2PC, we hold the
                    prepare_commit mutex across
                    both phases. In that case, we
                    defer flush of the logs to disk
                    until after we release the
                    mutex. */
    bool        must_flush_log_later;/*!< this flag is set to TRUE in
                    trx_commit() if flush_log_later was
                    TRUE, and there were modifications by
                    the transaction; in that case we must
                    flush the log in
                    trx_commit_complete_for_mysql() */
    ulint       duplicates; /*!< TRX_DUP_IGNORE | TRX_DUP_REPLACE */
    bool        has_search_latch;
                    /*!< TRUE if this trx has latched the
                    search system latch in S-mode */
    ulint       search_latch_timeout;
                    /*!< If we notice that someone is
                    waiting for our S-lock on the search
                    latch to be released, we wait in
                    row0sel.cc for BTR_SEA_TIMEOUT new
                    searches until we try to keep
                    the search latch again over
                    calls from MySQL; this is intended
                    to reduce contention on the search
                    latch */
    trx_dict_op_t   dict_operation; /**< @see enum trx_dict_op */

    /* Fields protected by the srv_conc_mutex. */
    bool        declared_to_be_inside_innodb;
                    /*!< this is TRUE if we have declared
                    this transaction in
                    srv_conc_enter_innodb to be inside the
                    InnoDB engine */
    ib_uint32_t     n_tickets_to_enter_innodb;
                    /*!< this can be > 0 only when
                    declared_to_... is TRUE; when we come
                    to srv_conc_innodb_enter, if the value
                    here is > 0, we decrement this by 1 */
    ib_uint32_t     dict_operation_lock_mode;
                    /*!< 0, RW_S_LATCH, or RW_X_LATCH:
                    the latch mode trx currently holds
                    on dict_operation_lock. Protected
                    by dict_operation_lock. */

    time_t      start_time; /*!< time the trx state last time became
                    TRX_STATE_ACTIVE */
    lsn_t       commit_lsn; /*!< lsn at the time of the commit */
    table_id_t  table_id;   /*!< Table to drop iff dict_operation
                    == TRX_DICT_OP_TABLE, or 0. */
    /*------------------------------*/
    THD*        mysql_thd;  /*!< MySQL thread handle corresponding
                    to this trx, or NULL */
    const char* mysql_log_file_name;
                    /*!< if MySQL binlog is used, this field
                    contains a pointer to the latest file
                    name; this is NULL if binlog is not
                    used */
    ib_int64_t  mysql_log_offset;
                    /*!< if MySQL binlog is used, this
                    field contains the end offset of the
                    binlog entry */
    /*------------------------------*/
    ib_uint32_t     n_mysql_tables_in_use; /*!< number of Innobase tables
                    used in the processing of the current
                    SQL statement in MySQL */
    ib_uint32_t     mysql_n_tables_locked;
                    /*!< how many tables the current SQL
                    statement uses, except those
                    in consistent read */   
    /*------------------------------*/
#ifdef UNIV_DEBUG
    /** The following two fields are mutually exclusive. */
    /* @{ */

    bool        in_rw_trx_list; /*!< true if in trx_sys->rw_trx_list */
    /* @} */
#endif /* UNIV_DEBUG */
    UT_LIST_NODE_T(trx_t)
            mysql_trx_list; /*!< list of transactions created for
                    MySQL; protected by trx_sys->mutex */
#ifdef UNIV_DEBUG
    bool        in_mysql_trx_list;
                    /*!< true if in
                    trx_sys->mysql_trx_list */
#endif /* UNIV_DEBUG */
    /*------------------------------*/
    dberr_t     error_state;    /*!< 0 if no error, otherwise error
                    number; NOTE That ONLY the thread
                    doing the transaction is allowed to
                    set this field: this is NOT protected
                    by any mutex */
    const dict_index_t*error_info;  /*!< if the error number indicates a
                    duplicate key error, a pointer to
                    the problematic index is stored here */
    ulint       error_key_num;  /*!< if the index creation fails to a
                    duplicate key error, a mysql key
                    number of that index is stored here */
    sess_t*     sess;       /*!< session of the trx, NULL if none */
    que_t*      graph;      /*!< query currently run in the session,
                    or NULL if none; NOTE that the query
                    belongs to the session, and it can
                    survive over a transaction commit, if
                    it is a stored procedure with a COMMIT
                    WORK statement, for instance */
    ReadView*   read_view;  /*!< consistent read view used in the
                    transaction or NULL if not yet set */
    /*------------------------------*/
    UT_LIST_BASE_NODE_T(trx_named_savept_t)
            trx_savepoints; /*!< savepoints set with SAVEPOINT ...,
                    oldest first */
    /*------------------------------*/
    ib_mutex_t  undo_mutex; /*!< mutex protecting the fields in this
                    section (down to undo_no_arr), EXCEPT
                    last_sql_stat_start, which can be
                    accessed only when we know that there
                    cannot be any activity in the undo
                    logs! */
    undo_no_t   undo_no;    /*!< next undo log record number to
                    assign; since the undo log is
                    private for a transaction, this
                    is a simple ascending sequence
                    with no gaps; thus it represents
                    the number of modified/inserted
                    rows in a transaction */
    trx_savept_t    last_sql_stat_start;
                    /*!< undo_no when the last sql statement
                    was started: in case of an error, trx
                    is rolled back down to this undo
                    number; see note at undo_mutex! */
    trx_rseg_t* rseg;       /*!< rollback segment assigned to the
                    transaction, or NULL if not assigned
                    yet */
    trx_undo_t* insert_undo;    /*!< pointer to the insert undo log, or
                    NULL if no inserts performed yet */
    trx_undo_t* update_undo;    /*!< pointer to the update undo log, or
                    NULL if no update performed yet */
    undo_no_t   roll_limit; /*!< least undo number to undo during
                    a rollback */
    ulint       pages_undone;   /*!< number of undo log pages undone
                    since the last undo log truncation */
    trx_undo_arr_t* undo_no_arr;    /*!< array of undo numbers of undo log
                    records which are currently processed
                    by a rollback operation */
    /*------------------------------*/
    ulint       n_autoinc_rows; /*!< no. of AUTO-INC rows required for
                    an SQL statement. This is useful for
                    multi-row INSERTs */
    ib_vector_t*    autoinc_locks;  /* AUTOINC locks held by this
                    transaction. Note that these are
                    also in the lock list trx_locks. This
                    vector needs to be freed explicitly
                    when the trx instance is destroyed.
                    Protected by lock_sys->mutex. */
    /*------------------------------*/
    bool        read_only;  /*!< true if transaction is flagged
                    as a READ-ONLY transaction.
                    if auto_commit && will_lock == 0
                    then it will be handled as a
                    AC-NL-RO-SELECT (Auto Commit Non-Locking
                    Read Only Select). A read only
                    transaction will not be assigned an
                    UNDO log. */
    bool        auto_commit;    /*!< true if it is an autocommit */
    ib_uint32_t     will_lock;  /*!< Will acquire some locks. Increment
                    each time we determine that a lock will
                    be acquired by the MySQL layer. */
    bool        ddl;        /*!< true if it is a transaction that
                    is being started for a DDL operation */
    /*------------------------------*/
    fts_trx_t*  fts_trx;    /*!< FTS information, or NULL if
                    transaction hasn't modified tables
                    with FTS indexes (yet). */
    doc_id_t    fts_next_doc_id;/* The document id used for updates */
    /*------------------------------*/
    ib_uint32_t     flush_tables;   /*!< if "covering" the FLUSH TABLES",
                    count of tables being flushed. */

    /*------------------------------*/
    bool        internal;       /*!< true if it is a system/internal
                    transaction background task. This
                    includes DDL transactions too.  Such
                    transactions are always treated as
                    read-write. */
    /*------------------------------*/
#ifdef UNIV_DEBUG
    ulint       start_line; /*!< Track where it was started from */
    const char* start_file; /*!< Filename where it was started */
#endif /* UNIV_DEBUG */
    /*------------------------------*/
    XID*        xid;            /*!< X/Open XA transaction
                                identification to identify a
                                transaction branch */
    bool        api_trx;    /*!< trx started by InnoDB API */
    bool        api_auto_commit;/*!< automatic commit */
    bool        read_write; /*!< if read and write operation */

    /*------------------------------*/
    char*       detailed_error; /*!< detailed error message for last
                            error, or empty. */
    ulint       magic_n;
};                                                                                          
```