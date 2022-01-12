#1.class Gtid_state

```cpp
/**
  Represents the state of the group log: the set of logged groups, the
  set of lost groups, the set of owned groups, the owner of each owned
  group, and a Mutex_cond_array that protects updates to groups of
  each SIDNO.

  Locking:

  This data structure has a read-write lock that protects the number
  of SIDNOs, and a Mutex_cond_array that contains one mutex per SIDNO.
  The rwlock is always the global_sid_lock.

  Access methods generally assert that the caller already holds the
  appropriate lock:

   - before accessing any global data, hold at least the rdlock.

   - before accessing a specific SIDNO in a Gtid_set or Owned_gtids
     (e.g., calling Gtid_set::_add_gtid(Gtid)), hold either the rdlock
     and the SIDNO's mutex lock; or the wrlock.  If you need to hold
     multiple mutexes, they must be acquired in order of increasing
     SIDNO.

   - before starting an operation that needs to access all SIDs
     (e.g. Gtid_set::to_string()), hold the wrlock.

  The access type (read/write) does not matter; the write lock only
  implies that the entire data structure is locked whereas the read
  lock implies that everything except SID-specific data is locked.
*/
class Gtid_state
{
public:
  /**
    The next_free_gno variable will be set with the supposed next free GNO
    every time a new GNO is delivered automatically or when a transaction is
    rolled back, releasing a GNO smaller than the last one delivered.
    It was introduced in an optimization of Gtid_state::get_automatic_gno and
    Gtid_state::generate_automatic_gtid functions.

    Locking scheme

    This variable can be read and modified in four places:
    - During server startup, holding global_sid_lock.wrlock;
    - By a client thread holding global_sid_lock.wrlock (doing a RESET MASTER);
    - By a client thread calling MYSQL_BIN_LOG::write_gtid function (often the
      group commit FLUSH stage leader). It will call
      Gtid_state::generate_automatic_gtid, that will acquire
      global_sid_lock.rdlock and lock_sidno(get_server_sidno()) when getting a
      new automatically generated GTID;
    - By a client thread rolling back, holding global_sid_lock.rdlock
      and lock_sidno(get_server_sidno()).
  */
  rpl_gno next_free_gno;

  /// Read-write lock that protects updates to the number of SIDs.
  mutable Checkable_rwlock *sid_lock;
  /// The Sid_map used by this Gtid_state.
  mutable Sid_map *sid_map;
  /// Contains one mutex/cond pair for every SIDNO.
  Mutex_cond_array sid_locks;
  /**
    The set of GTIDs that existed in some previously purged binary log.
    This is always a subset of executed_gtids.
  */
  Gtid_set lost_gtids;
  
  /*
    The set of GTIDs that has been executed and
    stored into gtid_executed table.
  */
  Gtid_set executed_gtids;
  /*
    The set of GTIDs that exists only in gtid_executed table, not in
    binlog files.
  */
  Gtid_set gtids_only_in_table;
  /* The previous GTIDs in the last binlog. */
  Gtid_set previous_gtids_logged;
  /// The set of GTIDs that are owned by some thread.
  Owned_gtids owned_gtids;
  /// The SIDNO for this server.
  rpl_sidno server_sidno;

  /// The number of anonymous transactions owned by any client.
  Atomic_int32 anonymous_gtid_count;
  /// The number of GTID-violating transactions that use GTID_NEXT=AUTOMATIC.
  Atomic_int32 automatic_gtid_violation_count;
  /// The number of GTID-violating transactions that use GTID_NEXT=AUTOMATIC.
  Atomic_int32 anonymous_gtid_violation_count;
  /// The number of clients that are executing
  /// WAIT_FOR_EXECUTED_GTID_SET or WAIT_UNTIL_SQL_THREAD_AFTER_GTIDS.
  Atomic_int32 gtid_wait_count;
...
...
}      
```