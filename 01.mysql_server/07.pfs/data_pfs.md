#1.struct PFS_thread

```cpp
/** Instrumented thread implementation. @see PSI_thread. */
struct PFS_ALIGNED PFS_thread : PFS_connection_slice
{
  static PFS_thread* get_current_thread(void);

  /** Thread instrumentation flag. */
  bool m_enabled;
  /** Current wait event in the event stack. */
  PFS_events_waits *m_events_waits_current;
  /** Event ID counter */
  ulonglong m_event_id;
  /**
    Internal lock.
    This lock is exclusively used to protect against races
    when creating and destroying PFS_thread.
    Do not use this lock to protect thread attributes,
    use one of @c m_stmt_lock or @c m_session_lock instead.
  */
  pfs_lock m_lock;
  /** Pins for filename_hash. */
  LF_PINS *m_filename_hash_pins;
  /** Pins for table_share_hash. */
  LF_PINS *m_table_share_hash_pins;
  /** Pins for setup_actor_hash. */
  LF_PINS *m_setup_actor_hash_pins;
  /** Pins for setup_object_hash. */
  LF_PINS *m_setup_object_hash_pins;
  /** Pins for host_hash. */
  LF_PINS *m_host_hash_pins;
  /** Pins for user_hash. */
  LF_PINS *m_user_hash_pins;
  /** Pins for account_hash. */
  LF_PINS *m_account_hash_pins;
  /** Pins for digest_hash. */
  LF_PINS *m_digest_hash_pins;
  /** Internal thread identifier, unique. */
  ulonglong m_thread_internal_id;
  /** Parent internal thread identifier. */
  ulonglong m_parent_thread_internal_id;
  /** External (SHOW PROCESSLIST) thread identifier, not unique. */
  ulong m_processlist_id;
  /** Thread class. */
  PFS_thread_class *m_class;

  /**
    Stack of events waits.
    This member holds the data for the table PERFORMANCE_SCHEMA.EVENTS_WAITS_CURRENT.
    Note that stack[0] is a dummy record that represents the parent stage/statement.
    For example, assuming the following tree:
    - STAGE ID 100
      - WAIT ID 101, parent STAGE 100
        - WAIT ID 102, parent wait 101
    the data in the stack will be:
    stack[0].m_event_id= 100, set by the stage instrumentation
    stack[0].m_event_type= STAGE, set by the stage instrumentation
    stack[0].m_nesting_event_id= unused
    stack[0].m_nesting_event_type= unused
    stack[1].m_event_id= 101
    stack[1].m_event_type= WAIT
    stack[1].m_nesting_event_id= stack[0].m_event_id= 100
    stack[1].m_nesting_event_type= stack[0].m_event_type= STAGE
    stack[2].m_event_id= 102
    stack[2].m_event_type= WAIT
    stack[2].m_nesting_event_id= stack[1].m_event_id= 101
    stack[2].m_nesting_event_type= stack[1].m_event_type= WAIT

    The whole point of the stack[0] record is to allow this optimization
    in the code, in the instrumentation for wait events:
      wait->m_nesting_event_id= (wait-1)->m_event_id;
      wait->m_nesting_event_type= (wait-1)->m_event_type;
    This code works for both the top level wait, and nested waits,
    and works without if conditions, which helps performances.
  */
  PFS_events_waits m_events_waits_stack[WAIT_STACK_SIZE];
  /** True if the circular buffer @c m_waits_history is full. */
  bool m_waits_history_full;
  /** Current index in the circular buffer @c m_waits_history. */
  uint m_waits_history_index;
  /**
    Waits history circular buffer.
    This member holds the data for the table
    PERFORMANCE_SCHEMA.EVENTS_WAITS_HISTORY.
  */
  PFS_events_waits *m_waits_history;

  /** True if the circular buffer @c m_stages_history is full. */
  bool m_stages_history_full;
  /** Current index in the circular buffer @c m_stages_history. */
  uint m_stages_history_index;
  /**
    Stages history circular buffer.
    This member holds the data for the table
    PERFORMANCE_SCHEMA.EVENTS_STAGES_HISTORY.
  */
  PFS_events_stages *m_stages_history;
  /** True if the circular buffer @c m_statements_history is full. */
  bool m_statements_history_full;
  /** Current index in the circular buffer @c m_statements_history. */
  uint m_statements_history_index;
  /**
    Statements history circular buffer.
    This member holds the data for the table
    PERFORMANCE_SCHEMA.EVENTS_STATEMENTS_HISTORY.
  */
  PFS_events_statements *m_statements_history;

  /**
    Internal lock, for session attributes.
    Statement attributes are expected to be updated in frequently,
    typically per session execution.
  */
  pfs_lock m_session_lock;
  /**
    User name.
    Protected by @c m_session_lock.
  */
  char m_username[USERNAME_LENGTH];
  /**
    Length of @c m_username.
    Protected by @c m_session_lock.
  */
  uint m_username_length;
  /**
    Host name.
    Protected by @c m_session_lock.
  */
  char m_hostname[HOSTNAME_LENGTH];
  /**
    Length of @c m_hostname.
    Protected by @c m_session_lock.
  */
  uint m_hostname_length;
  /**
    Database name.
    Protected by @c m_stmt_lock.
  */
  char m_dbname[NAME_LEN];
  /**
    Length of @c m_dbname.
    Protected by @c m_stmt_lock.
  */
  uint m_dbname_length;
  /** Current command. */
  int m_command;
  /** Start time. */
  time_t m_start_time;
  /**
    Internal lock, for statement attributes.
    Statement attributes are expected to be updated frequently,
    typically per statement execution.
  */
  pfs_lock m_stmt_lock;
  /** Processlist state (derived from stage). */
  PFS_stage_key m_stage;
  /**
    Processlist info.
    Protected by @c m_stmt_lock.
  */
  char m_processlist_info[COL_INFO_SIZE];
  /**
    Length of @c m_processlist_info_length.
    Protected by @c m_stmt_lock.
  */
  uint m_processlist_info_length;

  PFS_events_stages m_stage_current;

  /** Size of @c m_events_statements_stack. */
  uint m_events_statements_count;
  PFS_events_statements *m_statement_stack;

  PFS_host *m_host;
  PFS_user *m_user;
  PFS_account *m_account;

  /** Reset session connect attributes */
  void reset_session_connect_attrs();

  /**
    Buffer for the connection attributes.
    Protected by @c m_session_lock.
  */
  char *m_session_connect_attrs;
  /**
    Length used by @c m_connect_attrs.
    Protected by @c m_session_lock.
  */
  uint m_session_connect_attrs_length;
  /**
    Character set in which @c m_connect_attrs are encoded.
    Protected by @c m_session_lock.
  */
  uint m_session_connect_attrs_cs_number;
};      
```