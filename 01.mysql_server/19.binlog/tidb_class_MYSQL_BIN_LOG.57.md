#1.class MYSQL_BIN_LOG

```cpp
/*
  TODO use mmap instead of IO_CACHE for binlog
  (mmap+fsync is two times faster than write+fsync)
*/

class MYSQL_BIN_LOG: public TC_LOG
{
  enum enum_log_state { LOG_OPENED, LOG_CLOSED, LOG_TO_BE_OPENED };

  /* LOCK_log is inited by init_pthread_objects() */
  mysql_mutex_t LOCK_log;
  char *name;
  char log_file_name[FN_REFLEN];
  char db[NAME_LEN + 1];
  bool write_error, inited;
  IO_CACHE log_file;
  const enum cache_type io_cache_type;

  /* POSIX thread objects are inited by init_pthread_objects() */
  mysql_mutex_t LOCK_index;
  mysql_mutex_t LOCK_commit;
  mysql_mutex_t LOCK_sync;
  mysql_mutex_t LOCK_binlog_end_pos;
  mysql_mutex_t LOCK_xids;
  mysql_cond_t update_cond;

  my_off_t binlog_end_pos;
  ulonglong bytes_written;
  IO_CACHE index_file;
  char index_file_name[FN_REFLEN];
  /*
    crash_safe_index_file is temp file used for guaranteeing
    index file crash safe when master server restarts.
  */
  IO_CACHE crash_safe_index_file;
  char crash_safe_index_file_name[FN_REFLEN];
  /*
    purge_file is a temp file used in purge_logs so that the index file
    can be updated before deleting files from disk, yielding better crash
    recovery. It is created on demand the first time purge_logs is called
    and then reused for subsequent calls. It is cleaned up in cleanup().
  */
  IO_CACHE purge_index_file;
  char purge_index_file_name[FN_REFLEN];
  /*
     The max size before rotation (usable only if log_type == LOG_BIN: binary
     logs and relay logs).
     For a binlog, max_size should be max_binlog_size.
     For a relay log, it should be max_relay_log_size if this is non-zero,
     max_binlog_size otherwise.
     max_size is set in init(), and dynamically changed (when one does SET
     GLOBAL MAX_BINLOG_SIZE|MAX_RELAY_LOG_SIZE) by fix_max_binlog_size and
     fix_max_relay_log_size).
  */
  ulong max_size;

  // current file sequence number for load data infile binary logging
  uint file_id;
  uint open_count;              // For replication
  int readers_count;

  /* pointer to the sync period variable, for binlog this will be
     sync_binlog_period, for relay log this will be
     sync_relay_log_period
  */
  uint *sync_period_ptr;
  uint sync_counter;

  ulong m_cur_bin_suffix;
  ulong m_cur_tmp_suffix;
  
  mysql_cond_t m_prep_xids_cond;
  Atomic_int32 m_prep_xids;

  /** Manage the stages in ordered_commit. */
  Stage_manager stage_manager;
public:
  /* Committed transactions timestamp */
   Logical_clock max_committed_transaction;
  /* "Prepared" transactions timestamp */
   Logical_clock transaction_counter;

private:
  Atomic_int32 log_state; /* atomic enum_log_state */

  /* The previous gtid set in relay log. */
  Gtid_set* previous_gtid_set_relaylog;

  bool snapshot_lock_acquired;
  
  /*
    True while rotating binlog, which is caused by logging Incident_log_event.
  */
  bool is_rotating_caused_by_incident;
};       

```
