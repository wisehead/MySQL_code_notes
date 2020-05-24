#<center>THD</center>

#1.class THD

```cpp
//sql_class.h

/**
  @class THD
  For each client connection we create a separate thread with THD serving as
  a thread/connection descriptor
*/

class THD :public MDL_context_owner,
           public Statement,
           public Open_tables_state
{
public:
  MDL_context mdl_context;

  /* Used to execute base64 coded binlog events in MySQL server */
  Relay_log_info* rli_fake;
  /* Slave applier execution context */
  Relay_log_info* rli_slave;

  void reset_for_next_command();
  /*
    Constant for THD::where initialization in the beginning of every query.

    It's needed because we do not save/restore THD::where normally during
    primary (non subselect) query execution.
  */
  static const char * const DEFAULT_WHERE;

#ifdef EMBEDDED_LIBRARY
  struct st_mysql  *mysql;
  unsigned long  client_stmt_id;
  unsigned long  client_param_count;
  struct st_mysql_bind *client_params;
  char *extra_data;
  ulong extra_length;
  struct st_mysql_data *cur_data;
  struct st_mysql_data *first_data;
  struct st_mysql_data **data_tail;
  void clear_data_list();
  struct st_mysql_data *alloc_new_dataset();
  /*
    In embedded server it points to the statement that is processed
    in the current query. We store some results directly in statement
    fields then.
  */
  struct st_mysql_stmt *current_stmt;
#endif
#ifdef HAVE_QUERY_CACHE
  Query_cache_tls query_cache_tls;
#endif
  NET     net;              // client connection descriptor
  /** Aditional network instrumentation for the server only. */
  NET_SERVER m_net_server_extension;
  scheduler_functions *scheduler;
  Protocol *protocol;           // Current protocol
  Protocol_text   protocol_text;    // Normal protocol
  Protocol_binary protocol_binary;  // Binary protocol
  HASH    user_vars;            // hash for user variables
  String  packet;           // dynamic buffer for network I/O
  String  convert_buffer;               // buffer for charset conversions
  struct  rand_struct rand;     // used for authentication
  struct  system_variables variables;   // Changeable local variables
  struct  system_status_var status_var; // Per thread statistic vars
  struct  system_status_var *initial_status_var; /* used by show status */
  THR_LOCK_INFO lock_info;              // Locking info of this thread
  /**
    Protects THD data accessed from other threads:
    - thd->query and thd->query_length (used by SHOW ENGINE
      INNODB STATUS and SHOW PROCESSLIST
    - thd->mysys_var (used by KILL statement and shutdown).
    Is locked when THD is deleted.
  */
  mysql_mutex_t LOCK_thd_data;

  /* all prepared statements and cursors of this connection */
  Statement_map stmt_map;
  /*
    A pointer to the stack frame of handle_one_connection(),
    which is called first in the thread for handling a client
  */
  char    *thread_stack;

  /**
    Currently selected catalog.
  */
  char *catalog;

  /**
    @note
    Some members of THD (currently 'Statement::db',
    'catalog' and 'query')  are set and alloced by the slave SQL thread
    (for the THD of that thread); that thread is (and must remain, for now)
    the only responsible for freeing these 3 members. If you add members
    here, and you add code to set them in replication, don't forget to
    free_them_and_set_them_to_0 in replication properly. For details see
    the 'err:' label of the handle_slave_sql() in sql/slave.cc.

    @see handle_slave_sql
  */

  Security_context main_security_ctx;
  Security_context *security_ctx;

  /*
    Points to info-string that we show in SHOW PROCESSLIST
    You are supposed to update thd->proc_info only if you have coded
    a time-consuming piece that MySQL can get stuck in for a long time.

    Set it using the  thd_proc_info(THD *thread, const char *message)
    macro/function.

    This member is accessed and assigned without any synchronization.
    Therefore, it may point only to constant (statically
    allocated) strings, which memory won't go away over time.
  */
  const char *proc_info;

private:
  unsigned int m_current_stage_key;
  /*
    Used in error messages to tell user in what part of MySQL we found an
    error. E. g. when where= "having clause", if fix_fields() fails, user
    will know that the error was in having clause.
  */
  const char *where;

  ulong client_capabilities;        /* What the client supports */
  ulong max_client_packet_length;

  HASH      handler_tables_hash;
  /*
    One thread can hold up to one named user-level lock. This variable
    points to a lock object if the lock is present. See item_func.cc and
    chapter 'Miscellaneous functions', for functions GET_LOCK, RELEASE_LOCK.
  */
  User_level_lock *ull;
#ifndef DBUG_OFF
  uint dbug_sentry; // watch out for memory corruption
#endif
  struct st_my_thread_var *mysys_var;

private:
  /**
    Type of current query: COM_STMT_PREPARE, COM_QUERY, etc.
    Set from first byte of the packet in do_command()
  */
  enum enum_server_command m_command;

public:
  uint32     unmasked_server_id;
  uint32     server_id;
  uint32     file_id;           // for LOAD DATA INFILE
  /* remote (peer) port */
  uint16 peer_port;
  struct timeval start_time;
  struct timeval user_time;
  // track down slow pthread_create
  ulonglong  prior_thr_create_utime, thr_create_utime;
  ulonglong  start_utime, utime_after_lock;
  thr_lock_type update_lock_default;
  Delayed_insert *di;

  /* <> 0 if we are inside of trigger or stored function. */
  uint in_sub_stmt;

  /* Do not set socket timeouts for wait_timeout (used with threadpool) */
  bool skip_wait_timeout;

  /**
    Used by fill_status() to avoid acquiring LOCK_status mutex twice
    when this function is called recursively (e.g. queries
    that contains SELECT on I_S.GLOBAL_STATUS with subquery on the
    same I_S table).
    Incremented each time fill_status() function is entered and
    decremented each time before it returns from the function.
  */
  uint fill_status_recursion_level;

  /* container for handler's private per-connection data */
  Ha_data ha_data[MAX_HA];

  /*
    Position of first event in Binlog
    *after* last event written by this
    thread.
  */
  event_coordinates binlog_next_event_pos;
  /*
     Ptr to row event extra data to be written to Binlog /
     received from Binlog.

   */
  uchar* binlog_row_event_extra_data;          

private:
  /**
    Indicate if the current statement should be discarded
    instead of written to the binlog.
    This is used to discard special statements, such as
    DML or DDL that affects only 'local' (non replicated)
    tables, such as performance_schema.*
  */
  binlog_filter_state m_binlog_filter_state;

  /**
    Indicates the format in which the current statement will be
    logged.  This can only be set from @c decide_logging_format().
  */
  enum_binlog_format current_stmt_binlog_format;

  /**
    Bit field for the state of binlog warnings.

    The first Lex::BINLOG_STMT_UNSAFE_COUNT bits list all types of
    unsafeness that the current statement has.

    This must be a member of THD and not of LEX, because warnings are
    detected and issued in different places (@c
    decide_logging_format() and @c binlog_query(), respectively).
    Between these calls, the THD->lex object may change; e.g., if a
    stored routine is invoked.  Only THD persists between the calls.
  */
  uint32 binlog_unsafe_warning_flags;

  /*
    Number of outstanding table maps, i.e., table maps in the
    transaction cache.
  */
  uint binlog_table_maps;
  /*
    MTS: db names listing to be updated by the query databases
  */
  List<char> *binlog_accessed_db_names;
  /**
    The binary log position of the transaction.

    The file and position are zero if the current transaction has not
    been written to the binary log.

    @see set_trans_pos
    @see get_trans_pos

    @todo Similar information is kept in the patch for BUG#11762277
    and by the master/slave heartbeat implementation.  We should merge
    these positions instead of maintaining three different ones.
   */
  /**@{*/
  const char *m_trans_log_file;
  char *m_trans_fixed_log_file;
  my_off_t m_trans_end_pos;
  /**@}*/
  Global_read_lock global_read_lock;

  Global_backup_lock backup_tables_lock;
  Global_backup_lock backup_binlog_lock;

  Field      *dup_field;
#ifndef __WIN__
  sigset_t signals;
#endif
#ifdef SIGNAL_WITH_VIO_SHUTDOWN
  Vio* active_vio;
#endif
  /*
    This is to track items changed during execution of a prepared
    statement/stored procedure. It's created by
    register_item_tree_change() in memory root of THD, and freed in
    rollback_item_tree_changes(). For conventional execution it's always
    empty.
  */
  Item_change_list change_list;
  /*
    A permanent memory area of the statement. For conventional
    execution, the parsed tree and execution runtime reside in the same
    memory root. In this case stmt_arena points to THD. In case of
    a prepared statement or a stored procedure statement, thd->mem_root
    conventionally points to runtime memory, and thd->stmt_arena
    points to the memory of the PS/SP, where the parsed tree of the
    statement resides. Whenever you need to perform a permanent
    transformation of a parsed tree, you should allocate new memory in
    stmt_arena, to allow correct re-execution of PS/SP.
    Note: in the parser, stmt_arena == thd, even for PS/SP.
  */
  Query_arena *stmt_arena;

  /*
    map for tables that will be updated for a multi-table update query
    statement, for other query statements, this will be zero.
  */
  table_map table_map_for_update;

  /* Tells if LAST_INSERT_ID(#) was called for the current statement */
  bool arg_of_last_insert_id_function;
  /*
    ALL OVER THIS FILE, "insert_id" means "*automatically generated* value for
    insertion into an auto_increment column".
  */
  /*
    This is the first autogenerated insert id which was *successfully*
    inserted by the previous statement (exactly, if the previous statement
    didn't successfully insert an autogenerated insert id, then it's the one
    of the statement before, etc).
    It can also be set by SET LAST_INSERT_ID=# or SELECT LAST_INSERT_ID(#).
    It is returned by LAST_INSERT_ID().
  */
  ulonglong  first_successful_insert_id_in_prev_stmt;
  /*
    Variant of the above, used for storing in statement-based binlog. The
    difference is that the one above can change as the execution of a stored
    function progresses, while the one below is set once and then does not
    change (which is the value which statement-based binlog needs).
  */
  ulonglong  first_successful_insert_id_in_prev_stmt_for_binlog;
  /*
    This is the first autogenerated insert id which was *successfully*
    inserted by the current statement. It is maintained only to set
    first_successful_insert_id_in_prev_stmt when statement ends.
  */
  ulonglong  first_successful_insert_id_in_cur_stmt;
  /*
    We follow this logic:
    - when stmt starts, first_successful_insert_id_in_prev_stmt contains the
    first insert id successfully inserted by the previous stmt.
    - as stmt makes progress, handler::insert_id_for_cur_row changes;
    every time get_auto_increment() is called,
    auto_inc_intervals_in_cur_stmt_for_binlog is augmented with the
    reserved interval (if statement-based binlogging).
    - at first successful insertion of an autogenerated value,
    first_successful_insert_id_in_cur_stmt is set to
    handler::insert_id_for_cur_row.
    - when stmt goes to binlog,
    auto_inc_intervals_in_cur_stmt_for_binlog is binlogged if
    non-empty.
    - when stmt ends, first_successful_insert_id_in_prev_stmt is set to
    first_successful_insert_id_in_cur_stmt.
  */
  /*
    stmt_depends_on_first_successful_insert_id_in_prev_stmt is set when
    LAST_INSERT_ID() is used by a statement.
    If it is set, first_successful_insert_id_in_prev_stmt_for_binlog will be
    stored in the statement-based binlog.
    This variable is CUMULATIVE along the execution of a stored function or
    trigger: if one substatement sets it to 1 it will stay 1 until the
    function/trigger ends, thus making sure that
    first_successful_insert_id_in_prev_stmt_for_binlog does not change anymore
    and is propagated to the caller for binlogging.
  */
  bool       stmt_depends_on_first_successful_insert_id_in_prev_stmt;
  /*
    List of auto_increment intervals reserved by the thread so far, for
    storage in the statement-based binlog.
    Note that its minimum is not first_successful_insert_id_in_cur_stmt:
    assuming a table with an autoinc column, and this happens:
    INSERT INTO ... VALUES(3);
    SET INSERT_ID=3; INSERT IGNORE ... VALUES (NULL);
    then the latter INSERT will insert no rows
    (first_successful_insert_id_in_cur_stmt == 0), but storing "INSERT_ID=3"
    in the binlog is still needed; the list's minimum will contain 3.
    This variable is cumulative: if several statements are written to binlog
    as one (stored functions or triggers are used) this list is the
    concatenation of all intervals reserved by all statements.
  */
  Discrete_intervals_list auto_inc_intervals_in_cur_stmt_for_binlog;
  /* Used by replication and SET INSERT_ID */
  Discrete_intervals_list auto_inc_intervals_forced;
  /*
    There is BUG#19630 where statement-based replication of stored
    functions/triggers with two auto_increment columns breaks.
    We however ensure that it works when there is 0 or 1 auto_increment
    column; our rules are
    a) on master, while executing a top statement involving substatements,
    first top- or sub- statement to generate auto_increment values wins the
    exclusive right to see its values be written to binlog (the write
    will be done by the statement or its caller), and the losers won't see
    their values be written to binlog.
    b) on slave, while replicating a top statement involving substatements,
    first top- or sub- statement to need to read auto_increment values from
    the master's binlog wins the exclusive right to read them (so the losers
    won't read their values from binlog but instead generate on their own).
    a) implies that we mustn't backup/restore
    auto_inc_intervals_in_cur_stmt_for_binlog.
    b) implies that we mustn't backup/restore auto_inc_intervals_forced.

    If there are more than 1 auto_increment columns, then intervals for
    different columns may mix into the
    auto_inc_intervals_in_cur_stmt_for_binlog list, which is logically wrong,
    but there is no point in preventing this mixing by preventing intervals
    from the secondly inserted column to come into the list, as such
    prevention would be wrong too.
    What will happen in the case of
    INSERT INTO t1 (auto_inc) VALUES(NULL);
    where t1 has a trigger which inserts into an auto_inc column of t2, is
    that in binlog we'll store the interval of t1 and the interval of t2 (when
    we store intervals, soon), then in slave, t1 will use both intervals, t2
    will use none; if t1 inserts the same number of rows as on master,
    normally the 2nd interval will not be used by t1, which is fine. t2's
    values will be wrong if t2's internal auto_increment counter is different
    from what it was on master (which is likely). In 5.1, in mixed binlogging
    mode, row-based binlogging is used for such cases where two
    auto_increment columns are inserted.
  */

  ulonglong  limit_found_rows;

private:
  /**
    Stores the result of ROW_COUNT() function.

    ROW_COUNT() function is a MySQL extention, but we try to keep it
    similar to ROW_COUNT member of the GET DIAGNOSTICS stack of the SQL
    standard (see SQL99, part 2, search for ROW_COUNT). It's value is
    implementation defined for anything except INSERT, DELETE, UPDATE.

    ROW_COUNT is assigned according to the following rules:

      - In my_ok():
        - for DML statements: to the number of affected rows;
        - for DDL statements: to 0.

      - In my_eof(): to -1 to indicate that there was a result set.

        We derive this semantics from the JDBC specification, where int
        java.sql.Statement.getUpdateCount() is defined to (sic) "return the
        current result as an update count; if the result is a ResultSet
        object or there are no more results, -1 is returned".

      - In my_error(): to -1 to be compatible with the MySQL C API and
        MySQL ODBC driver.

      - For SIGNAL statements: to 0 per WL#2110 specification (see also
        sql_signal.cc comment). Zero is used since that's the "default"
        value of ROW_COUNT in the diagnostics area.
  */

  longlong m_row_count_func;    /* For the ROW_COUNT() function */
  ha_rows    cuted_fields;

private:
  /**
    Number of rows we actually sent to the client, including "synthetic"
    rows in ROLLUP etc.
  */
  ha_rows m_sent_row_count;

  /**
    Number of rows read and/or evaluated for a statement. Used for
    slow log reporting.

    An examined row is defined as a row that is read and/or evaluated
    according to a statement condition, including in
    create_sort_index(). Rows may be counted more than once, e.g., a
    statement including ORDER BY could possibly evaluate the row in
    filesort() before reading it for e.g. update.
  */
  ha_rows m_examined_row_count;

private:
  USER_CONN *m_user_connect;

  const CHARSET_INFO *db_charset;
#if defined(ENABLED_PROFILING)
  PROFILING  profiling;
#endif

  /** Current statement instrumentation. */
  PSI_statement_locker *m_statement_psi;
#ifdef HAVE_PSI_STATEMENT_INTERFACE
  /** Current statement instrumentation state. */
  PSI_statement_locker_state m_statement_state;
#endif /* HAVE_PSI_STATEMENT_INTERFACE */
  /** Idle instrumentation. */
  PSI_idle_locker *m_idle_psi;
#ifdef HAVE_PSI_IDLE_INTERFACE
  /** Idle instrumentation state. */
  PSI_idle_locker_state m_idle_state;
#endif /* HAVE_PSI_IDLE_INTERFACE */
  /** True if the server code is IDLE for this connection. */
  bool m_server_idle;

  /*
    Id of current query. Statement can be reused to execute several queries
    query_id is global in context of the whole MySQL server.
    ID is automatically generated from mutex-protected counter.
    It's used in handler code for various purposes: to check which columns
    from table are necessary for this select, to check if it's necessary to
    update auto-updatable fields (like auto_increment and timestamp).
  */
  query_id_t query_id;
  ulong      col_access;

  /* Statement id is thread-wide. This counter is used to generate ids */
  ulong      statement_id_counter;
  ulong      rand_saved_seed1, rand_saved_seed2;
  pthread_t  real_id;                           /* For debugging */
  my_thread_id  thread_id;
  uint       tmp_table;
  uint       server_status,open_options;
  enum enum_thread_type system_thread;
  uint       select_number;             //number of select (used for EXPLAIN)
  /*
    Current or next transaction isolation level.
    When a connection is established, the value is taken from
    @@session.tx_isolation (default transaction isolation for
    the session), which is in turn taken from @@global.tx_isolation
    (the global value).
    If there is no transaction started, this variable
    holds the value of the next transaction's isolation level.
    When a transaction starts, the value stored in this variable
    becomes "actual".
    At transaction commit or rollback, we assign this variable
    again from @@session.tx_isolation.
    The only statement that can otherwise change the value
    of this variable is SET TRANSACTION ISOLATION LEVEL.
    Its purpose is to effect the isolation level of the next
    transaction in this session. When this statement is executed,
    the value in this variable is changed. However, since
    this statement is only allowed when there is no active
    transaction, this assignment (naturally) only affects the
    upcoming transaction.
    At the end of the current active transaction the value is
    be reset again from @@session.tx_isolation, as described
    above.
  */
  enum_tx_isolation tx_isolation;
  /*
    Current or next transaction access mode.
    See comment above regarding tx_isolation.
  */
  bool              tx_read_only;
  enum_check_fields count_cuted_fields;

  DYNAMIC_ARRAY user_var_events;        /* For user variables replication */
  MEM_ROOT      *user_var_events_alloc; /* Allocate above array elements here */

  /**
    Used by MYSQL_BIN_LOG to maintain the commit queue for binary log
    group commit.
  */
  THD *next_to_commit;

  const char * _semi_sync_group_name;
  /*
    Error code from committing or rolling back the transaction.
  */
  enum Commit_error
  {
    CE_NONE= 0,
    CE_FLUSH_ERROR,
    CE_COMMIT_ERROR,
    CE_ERROR_COUNT
  } commit_error;

  /*
    Define durability properties that engines may check to
    improve performance.
  */
  enum durability_properties durability_property;

  /*
    If checking this in conjunction with a wait condition, please
    include a check after enter_cond() if you want to avoid a race
    condition. For details see the implementation of awake(),
    especially the "broadcast" part.
  */
  enum killed_state
  {
    NOT_KILLED=0,
    KILL_BAD_DATA=1,
    KILL_CONNECTION=ER_SERVER_SHUTDOWN,
    KILL_QUERY=ER_QUERY_INTERRUPTED,
    KILL_TIMEOUT=ER_QUERY_TIMEOUT,
    KILLED_NO_VALUE      /* means neither of the states */
  };
  killed_state volatile killed;

  /* scramble - random string sent to client on handshake */
  char       scramble[SCRAMBLE_LENGTH+1];

  /// @todo: slave_thread is completely redundant, we should use 'system_thread' instead /sven
  bool       slave_thread, one_shot_set;
  bool       extra_port;                        /* If extra connection */
  bool       no_errors;
  uchar      password;
  /**
    Set to TRUE if execution of the current compound statement
    can not continue. In particular, disables activation of
    CONTINUE or EXIT handlers of stored routines.
    Reset in the end of processing of the current user request, in
    @see mysql_reset_thd_for_next_command().
  */
  bool is_fatal_error;
  /**
    Set by a storage engine to request the entire
    transaction (that possibly spans multiple engines) to
    rollback. Reset in ha_rollback.
  */
  bool       transaction_rollback_request;
  /**
    TRUE if we are in a sub-statement and the current error can
    not be safely recovered until we left the sub-statement mode.
    In particular, disables activation of CONTINUE and EXIT
    handlers inside sub-statements. E.g. if it is a deadlock
    error and requires a transaction-wide rollback, this flag is
    raised (traditionally, MySQL first has to close all the reads
    via @see handler::ha_index_or_rnd_end() and only then perform
    the rollback).
    Reset to FALSE when we leave the sub-statement mode.
  */
  bool       is_fatal_sub_stmt_error;
  bool       query_start_used, query_start_usec_used;
  bool       rand_used, time_zone_used;
  /* for IS NULL => = last_insert_id() fix in remove_eq_conds() */
  bool       substitute_null_with_insert_id;
  bool       in_lock_tables;
  /**
    True if a slave error. Causes the slave to stop. Not the same
    as the statement execution error (is_error()), since
    a statement may be expected to return an error, e.g. because
    it returned an error on master, and this is OK on the slave.
  */
  bool       is_slave_error;
  bool       bootstrap;

  /**  is set if some thread specific value(s) used in a statement. */
  bool       thread_specific_used;
  /**
    is set if a statement accesses a temporary table created through
    CREATE TEMPORARY TABLE.
  */
  bool       charset_is_system_charset, charset_is_collation_connection;
  bool       charset_is_character_set_filesystem;
  bool       enable_slow_log;   /* enable slow log for current statement */
  bool       abort_on_warning;
  bool       got_warning;       /* Set on call to push_warning() */
  /* set during loop of derived table processing */
  bool       derived_tables_processing;
  my_bool    tablespace_op; /* This is TRUE in DISCARD/IMPORT TABLESPACE */

  /** Current SP-runtime context. */
  sp_rcontext *sp_runtime_ctx;
  sp_cache   *sp_proc_cache;
  sp_cache   *sp_func_cache;

  /** number of name_const() substitutions, see sp_head.cc:subst_spvars() */
  uint       query_name_consts;

  /*
    If we do a purge of binary logs, log index info of the threads
    that are currently reading it needs to be adjusted. To do that
    each thread that is using LOG_INFO needs to adjust the pointer to it
  */
  LOG_INFO*  current_linfo;
  NET*       slave_net;         // network connection from slave -> m.
  /* Used by the sys_var class to store temporary values */
  union
  {
    my_bool   my_bool_value;
    long      long_value;
    ulong     ulong_value;
    ulonglong ulonglong_value;
    double    double_value;
  } sys_var_tmp;

  struct {
    /*
      If true, mysql_bin_log::write(Log_event) call will not write events to
      binlog, and maintain 2 below variables instead (use
      mysql_bin_log.start_union_events to turn this on)
    */
    bool do_union;
    /*
      If TRUE, at least one mysql_bin_log::write(Log_event) call has been
      made after last mysql_bin_log.start_union_events() call.
    */
    bool unioned_events;
    /*
      If TRUE, at least one mysql_bin_log::write(Log_event e), where
      e.cache_stmt == TRUE call has been made after last
      mysql_bin_log.start_union_events() call.
    */
    bool unioned_events_trans;

    /*
      'queries' (actually SP statements) that run under inside this binlog
      union have thd->query_id >= first_query_id.
    */
    query_id_t first_query_id;
  } binlog_evt_union;

  /**
    Internal parser state.
    Note that since the parser is not re-entrant, we keep only one parser
    state here. This member is valid only when executing code during parsing.
  */
  Parser_state *m_parser_state;

  Locked_tables_list locked_tables_list;

#ifdef WITH_PARTITION_STORAGE_ENGINE
  partition_info *work_part_info;
#endif

#ifndef EMBEDDED_LIBRARY
  /**
    Array of active audit plugins which have been used by this THD.
    This list is later iterated to invoke release_thd() on those
    plugins.
  */
  DYNAMIC_ARRAY audit_class_plugins;
  /**
    Array of bits indicating which audit classes have already been
    added to the list of audit plugins which are currently in use.
  */
  unsigned long audit_class_mask[MYSQL_AUDIT_CLASS_MASK_SIZE];
#endif

#if defined(ENABLED_DEBUG_SYNC)
  /* Debug Sync facility. See debug_sync.cc. */
  struct st_debug_sync_control *debug_sync_control;
#endif /* defined(ENABLED_DEBUG_SYNC) */

  // We don't want to load/unload plugins for unit tests.
  bool m_enable_plugins;
  /**
    If this thread owns a single GTID, then owned_gtid is set to that
    group.  If this thread does not own any GTID at all,
    owned_gtid.sidno==0.  If owned_gtid_set contains the set of owned
    gtids, owned_gtid.sidno==-1.
  */
  Gtid owned_gtid;
  /**
    If this thread owns a set of GTIDs (i.e., GTID_NEXT_LIST != NULL),
    then this member variable contains the subset of those GTIDs that
    are owned by this thread.
  */
  Gtid_set owned_gtid_set;
  /*
    There are some statements (like OPTIMIZE TABLE, ANALYZE TABLE and
    REPAIR TABLE) that might call trans_rollback_stmt() and also will be
    sucessfully executed and will have to go to the binary log.
    For these statements, the skip_gtid_rollback flag must be set to avoid
    problems when the statement is executed with a GTID_NEXT set to GTID_GROUP
    (like the SQL thread do when applying events from other server).
    When this flag is set, a call to gtid_rollback() will do nothing.
  */
  bool skip_gtid_rollback;        
private:

  /** The current internal error handler for this thread, or NULL. */
  Internal_error_handler *m_internal_handler;

  /**
    The lex to hold the parsed tree of conventional (non-prepared) queries.
    Whereas for prepared and stored procedure statements we use an own lex
    instance for each new query, for conventional statements we reuse
    the same lex. (@see mysql_parse for details).
  */
  LEX main_lex;
  /**
    This memory root is used for two purposes:
    - for conventional queries, to allocate structures stored in main_lex
    during parsing, and allocate runtime data (execution plan, etc.)
    during execution.
    - for prepared queries, only to allocate runtime data. The parsed
    tree itself is reused between executions and thus is stored elsewhere.
  */
  MEM_ROOT main_mem_root;
  Diagnostics_area main_da;
  Diagnostics_area *m_stmt_da;

  /**
    It will be set TURE if CURRENT_USER() is called in account management
    statements or default definer is set in CREATE/ALTER SP, SF, Event,
    TRIGGER or VIEW statements.

    Current user will be binlogged into Query_log_event if current_user_used
    is TRUE; It will be stored into invoker_host and invoker_user by SQL thread.
   */
  bool m_binlog_invoker;

  /**
    It points to the invoker in the Query_log_event.
    SQL thread use it as the default definer in CREATE/ALTER SP, SF, Event,
    TRIGGER or VIEW statements or current user in account management
    statements if it is not NULL.
   */
  LEX_STRING invoker_user;
  LEX_STRING invoker_host;
};  
                          
```

