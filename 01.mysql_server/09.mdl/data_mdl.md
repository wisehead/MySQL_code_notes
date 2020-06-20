#0.importanct structs

```cpp
首先：enum_mdl_namespace 表示mdl_request的作用域，比如alter table操作，需要获取TABLE作用域。

然后：enum_mdl_duration 表示mdl_request的持久类型，比如alter table操作，类型是MDL_STATEMENT，即语句结束，就释放mdl锁。又比如autocommit=0；select 操作，类型是MDL_TRANSACTION，必须在显示的commit，才释放mdl锁。

最后：enum_mdl_type 表示mdl_request的lock类型，根据这个枚举类型，来判断是否兼容和互斥。
```

#1.class MDL_request

```cpp
/**
  A pending metadata lock request.

  A lock request and a granted metadata lock are represented by
  different classes because they have different allocation
  sites and hence different lifetimes. The allocation of lock requests is
  controlled from outside of the MDL subsystem, while allocation of granted
  locks (tickets) is controlled within the MDL subsystem.

  MDL_request is a C structure, you don't need to call a constructor
  or destructor for it.
*/

class MDL_request
{
public:
  /** Type of metadata lock. */
  enum          enum_mdl_type type;
  /** Duration for requested lock. */
  enum enum_mdl_duration duration;

  /**
    Pointers for participating in the list of lock requests for this context.
  */
  MDL_request *next_in_list;
  MDL_request **prev_in_list;
  /**
    Pointer to the lock ticket object for this lock request.
    Valid only if this lock request is satisfied.
  */
  MDL_ticket *ticket;

  /** A lock is requested based on a fully qualified name and type. */
  MDL_key key;
};  
```

#3.class MDL_key

```cpp
/**
  Metadata lock object key.

  A lock is requested or granted based on a fully qualified name and type.
  E.g. They key for a table consists of <0 (=table)>+<database>+<table name>.
  Elsewhere in the comments this triple will be referred to simply as "key"
  or "name".
*/

class MDL_key
{
private:
  uint16 m_length;
  uint16 m_db_name_length;
  char m_ptr[MAX_MDLKEY_LENGTH];
  static PSI_stage_info m_namespace_to_wait_state_name[NAMESPACE_END];
};


                            
```

#4.enum enum_mdl_namespace

```cpp
  /**
    Object namespaces.
    Sic: when adding a new member to this enum make sure to
    update m_namespace_to_wait_state_name array in mdl.cc!

    Different types of objects exist in different namespaces
     - TABLE is for tables and views.
     - FUNCTION is for stored functions.
     - PROCEDURE is for stored procedures.
     - TRIGGER is for triggers.
     - EVENT is for event scheduler events
    Note that although there isn't metadata locking on triggers,
    it's necessary to have a separate namespace for them since
    MDL_key is also used outside of the MDL subsystem.
  */
  enum enum_mdl_namespace { GLOBAL=0,
                            BACKUP,
                            SCHEMA,
                            TABLE,
                            FUNCTION,
                            PROCEDURE,
                            TRIGGER,
                            EVENT,
                            COMMIT,
                            USER_LOCK,           /* user level locks. */
                            BINLOG,
                            /* This should be the last ! */
                            NAMESPACE_END };
```

#5.class MDL_map

```cpp
/**
  A collection of all MDL locks. A singleton,
  there is only one instance of the map in the server.
  Contains instances of MDL_map_partition
*/

class MDL_map
{
public:
  void init();
  void destroy();
  MDL_lock *find_or_insert(const MDL_key *key);
  void remove(MDL_lock *lock);
  unsigned long get_lock_owner(const MDL_key *key);
private:
  /** Array of partitions where the locks are actually stored. */
  Dynamic_array<MDL_map_partition *> m_partitions;
  /** Pre-allocated MDL_lock object for GLOBAL namespace. */
  MDL_lock *m_global_lock;
  /** Pre-allocated MDL_lock object for COMMIT namespace. */
  MDL_lock *m_commit_lock;
  /** Pre-allocated MDL_lock object for BACKUP namespace. */
  MDL_lock *m_backup_lock;
  /** Pre-allocated MDL_lock object for BINLOG namespace */
  MDL_lock *m_binlog_lock;
};
```

#6.class MDL_context

```cpp
/**
  Context of the owner of metadata locks. I.e. each server
  connection has such a context.
*/

class MDL_context
{
public:
  typedef I_P_List<MDL_ticket,
                   I_P_List_adapter<MDL_ticket,
                                    &MDL_ticket::next_in_context,
                                    &MDL_ticket::prev_in_context> >
          Ticket_list;

  typedef Ticket_list::Iterator Ticket_iterator;
public:
  /**
    If our request for a lock is scheduled, or aborted by the deadlock
    detector, the result is recorded in this class.
  */
  MDL_wait m_wait;
private:
  /**
    Lists of all MDL tickets acquired by this connection.

    Lists of MDL tickets:
    ---------------------
    The entire set of locks acquired by a connection can be separated
    in three subsets according to their duration: locks released at
    the end of statement, at the end of transaction and locks are
    released explicitly.

    Statement and transactional locks are locks with automatic scope.
    They are accumulated in the course of a transaction, and released
    either at the end of uppermost statement (for statement locks) or
    on COMMIT, ROLLBACK or ROLLBACK TO SAVEPOINT (for transactional
    locks). They must not be (and never are) released manually,
    i.e. with release_lock() call.

    Tickets with explicit duration are taken for locks that span
    multiple transactions or savepoints.
    These are: HANDLER SQL locks (HANDLER SQL is
    transaction-agnostic), LOCK TABLES locks (you can COMMIT/etc
    under LOCK TABLES, and the locked tables stay locked), user level
    locks (GET_LOCK()/RELEASE_LOCK() functions) and
    locks implementing "global read lock".

    Statement/transactional locks are always prepended to the
    beginning of the appropriate list. In other words, they are
    stored in reverse temporal order. Thus, when we rollback to
    a savepoint, we start popping and releasing tickets from the
    front until we reach the last ticket acquired after the savepoint.

    Locks with explicit duration are not stored in any
    particular order, and among each other can be split into
    four sets:

    [LOCK TABLES locks] [USER locks] [HANDLER locks] [GLOBAL READ LOCK locks]

    The following is known about these sets:
    * GLOBAL READ LOCK locks are always stored last.
      This is because one can't say SET GLOBAL read_only=1 or
      FLUSH TABLES WITH READ LOCK if one has locked tables. One can,
      however, LOCK TABLES after having entered the read only mode.
      Note, that subsequent LOCK TABLES statement will unlock the previous
      set of tables, but not the GRL!
      There are no HANDLER locks after GRL locks because
      SET GLOBAL read_only performs a FLUSH TABLES WITH
      READ LOCK internally, and FLUSH TABLES, in turn, implicitly
      closes all open HANDLERs.
      However, one can open a few HANDLERs after entering the
      read only mode.
    * LOCK TABLES locks include intention exclusive locks on
      involved schemas and global intention exclusive lock.
  */
  Ticket_list m_tickets[MDL_DURATION_END];
  MDL_context_owner *m_owner;
  /**
    TRUE -  if for this context we will break protocol and try to
            acquire table-level locks while having only S lock on
            some table.
            To avoid deadlocks which might occur during concurrent
            upgrade of SNRW lock on such object to X lock we have to
            abort waits for table-level locks for such connections.
    FALSE - Otherwise.
  */
  bool m_needs_thr_lock_abort;

  /**
    Read-write lock protecting m_waiting_for member.

    @note The fact that this read-write lock prefers readers is
          important as deadlock detector won't work correctly
          otherwise. @sa Comment for MDL_lock::m_rwlock.
  */
  mysql_prlock_t m_LOCK_waiting_for;
  /**
    Tell the deadlock detector what metadata lock or table
    definition cache entry this session is waiting for.
    In principle, this is redundant, as information can be found
    by inspecting waiting queues, but we'd very much like it to be
    readily available to the wait-for graph iterator.
   */
  MDL_wait_for_subgraph *m_waiting_for;
};
        
```

#7.enum enum_mdl_duration

```cpp
enum enum_mdl_duration {
  /**
    Locks with statement duration are automatically released at the end
    of statement or transaction.
  */
  MDL_STATEMENT= 0,
  /**
    Locks with transaction duration are automatically released at the end
    of transaction.
  */
  MDL_TRANSACTION,
  /**
    Locks with explicit duration survive the end of statement and transaction.
    They have to be released explicitly by calling MDL_context::release_lock().
  */
  MDL_EXPLICIT,
  /* This should be the last ! */
  MDL_DURATION_END };
```

#8.MDL_lock

```cpp
/**
  The lock context. Created internally for an acquired lock.
  For a given name, there exists only one MDL_lock instance,
  and it exists only when the lock has been granted.
  Can be seen as an MDL subsystem's version of TABLE_SHARE.

  This is an abstract class which lacks information about
  compatibility rules for lock types. They should be specified
  in its descendants.
*/

class MDL_lock
{
public:
  typedef unsigned short bitmap_t;

  typedef Ticket_list::List::Iterator Ticket_iterator;

public:
  /** The key of the object (data) being protected. */
  MDL_key key;
  /**
    Read-write lock protecting this lock context.

    @note The fact that we use read-write lock prefers readers here is
          important as deadlock detector won't work correctly otherwise.

          For example, imagine that we have following waiters graph:

                       ctxA -> obj1 -> ctxB -> obj1 -|
                        ^                            |
                        |----------------------------|

          and both ctxA and ctxB start deadlock detection process:

            ctxA read-locks obj1             ctxB read-locks obj2
            ctxA goes deeper                 ctxB goes deeper

          Now ctxC comes in who wants to start waiting on obj1, also
          ctxD comes in who wants to start waiting on obj2.

            ctxC tries to write-lock obj1   ctxD tries to write-lock obj2
            ctxC is blocked                 ctxD is blocked

          Now ctxA and ctxB resume their search:

            ctxA tries to read-lock obj2    ctxB tries to read-lock obj1

          If m_rwlock prefers writes (or fair) both ctxA and ctxB would be
          blocked because of pending write locks from ctxD and ctxC
          correspondingly. Thus we will get a deadlock in deadlock detector.
          If m_wrlock prefers readers (actually ignoring pending writers is
          enough) ctxA and ctxB will continue and no deadlock will occur.
  */
  mysql_prlock_t m_rwlock;
  /** List of granted tickets for this lock. */
  Ticket_list m_granted;
  /** Tickets for contexts waiting to acquire a lock. */
  Ticket_list m_waiting;

  /**
    Number of times high priority lock requests have been granted while
    low priority lock requests were waiting.
  */
  ulong m_hog_lock_count;
public:
  /**
    These three members are used to make it possible to separate
    the MDL_map_partition::m_mutex mutex and MDL_lock::m_rwlock in
    MDL_map::find_or_insert() for increased scalability.
    The 'm_is_destroyed' member is only set by destroyers that
    have both the MDL_map_partition::m_mutex and MDL_lock::m_rwlock, thus
    holding any of the mutexes is sufficient to read it.
    The 'm_ref_usage; is incremented under protection by
    MDL_map_partition::m_mutex, but when 'm_is_destroyed' is set to TRUE, this
    member is moved to be protected by the MDL_lock::m_rwlock.
    This means that the MDL_map::find_or_insert() which only
    holds the MDL_lock::m_rwlock can compare it to 'm_ref_release'
    without acquiring MDL_map_partition::m_mutex again and if equal
    it can also destroy the lock object safely.
    The 'm_ref_release' is incremented under protection by
    MDL_lock::m_rwlock.
    Note since we are only interested in equality of these two
    counters we don't have to worry about overflows as long as
    their size is big enough to hold maximum number of concurrent
    threads on the system.
  */
  uint m_ref_usage;
  uint m_ref_release;
  bool m_is_destroyed;
  /**
    We use the same idea and an additional version counter to support
    caching of unused MDL_lock object for further re-use.
    This counter is incremented while holding both MDL_map_partition::m_mutex
    and MDL_lock::m_rwlock locks each time when a MDL_lock is moved from
    the partitioned hash to the paritioned unused objects list (or destroyed).
    A thread, which has found a MDL_lock object for the key in the hash
    and then released the MDL_map_partition::m_mutex before acquiring the
    MDL_lock::m_rwlock, can determine that this object was moved to the
    unused objects list (or destroyed) while it held no locks by comparing
    the version value which it read while holding the MDL_map_partition::m_mutex
    with the value read after acquiring the MDL_lock::m_rwlock.
    Note that since it takes several years to overflow this counter such
    theoretically possible overflows should not have any practical effects.
  */
  ulonglong m_version;
  /**
    Partition of MDL_map where the lock is stored.
  */
  MDL_map_partition *m_map_part;
};    
```


#9.class Ticket_list

```cpp
  class Ticket_list
  {
  public:
    typedef I_P_List<MDL_ticket,
                     I_P_List_adapter<MDL_ticket,
                                      &MDL_ticket::next_in_lock,
                                      &MDL_ticket::prev_in_lock>,
                     I_P_List_null_counter,
                     I_P_List_fast_push_back<MDL_ticket> >
            List;
    operator const List &() const { return m_list; }
    Ticket_list() :m_bitmap(0) {}

    void add_ticket(MDL_ticket *ticket);
    void remove_ticket(MDL_ticket *ticket);
    bool is_empty() const { return m_list.is_empty(); }
    bitmap_t bitmap() const { return m_bitmap; }
  private:
    void clear_bit_if_not_in_list(enum_mdl_type type);
  private:
    /** List of tickets. */
    List m_list;
    /** Bitmap of types of tickets in this list. */
    bitmap_t m_bitmap;
  };
```

#10.class MDL_wait

```cpp
/**
  A reliable way to wait on an MDL lock.
*/

class MDL_wait
{
public:
  MDL_wait();
  ~MDL_wait();

  enum enum_wait_status { EMPTY = 0, GRANTED, VICTIM, TIMEOUT, KILLED };

  bool set_status(enum_wait_status result_arg);
  enum_wait_status get_status();
  void reset_status();
  enum_wait_status timed_wait(MDL_context_owner *owner,
                              struct timespec *abs_timeout,
                              bool signal_timeout,
                              const PSI_stage_info *wait_state_name);
private:
  /**
    Condvar which is used for waiting until this context's pending
    request can be satisfied or this thread has to perform actions
    to resolve a potential deadlock (we subscribe to such
    notification by adding a ticket corresponding to the request
    to an appropriate queue of waiters).
  */
  mysql_mutex_t m_LOCK_wait_status;
  mysql_cond_t m_COND_wait_status;
  enum_wait_status m_wait_status;
};
```

#11.MDL_ticket

```cpp
/**
  A granted metadata lock.

  @warning MDL_ticket members are private to the MDL subsystem.

  @note Multiple shared locks on a same object are represented by a
        single ticket. The same does not apply for other lock types.

  @note There are two groups of MDL_ticket members:
        - "Externally accessible". These members can be accessed from
          threads/contexts different than ticket owner in cases when
          ticket participates in some list of granted or waiting tickets
          for a lock. Therefore one should change these members before
          including then to waiting/granted lists or while holding lock
          protecting those lists.
        - "Context private". Such members are private to thread/context
          owning this ticket. I.e. they should not be accessed from other
          threads/contexts.
*/

class MDL_ticket : public MDL_wait_for_subgraph
{
public:
  /**
    Pointers for participating in the list of lock requests for this context.
    Context private.
  */
  MDL_ticket *next_in_context;
  MDL_ticket **prev_in_context;
  /**
    Pointers for participating in the list of satisfied/pending requests
    for the lock. Externally accessible.
  */
  MDL_ticket *next_in_lock;
  MDL_ticket **prev_in_lock;


private:
  friend class MDL_context;
private:
  /** Type of metadata lock. Externally accessible. */
  enum enum_mdl_type m_type;
#ifndef DBUG_OFF
  /**
    Duration of lock represented by this ticket.
    Context private. Debug-only.
  */
  enum_mdl_duration m_duration;
#endif
  /**
    Context of the owner of the metadata lock ticket. Externally accessible.
  */
  MDL_context *m_ctx;

  /**
    Pointer to the lock object for this lock ticket. Externally accessible.
  */
  MDL_lock *m_lock;
};
```

#12.MDL_scoped_lock

```cpp
  switch (mdl_key->mdl_namespace())
  {
    case MDL_key::GLOBAL:
    case MDL_key::SCHEMA:
    case MDL_key::COMMIT:
    case MDL_key::BACKUP:
    case MDL_key::BINLOG:
      return new (std::nothrow) MDL_scoped_lock(mdl_key, map_part);
    default:
      return new (std::nothrow) MDL_object_lock(mdl_key, map_part);
  }

/**
  An implementation of the scoped metadata lock. The only locking modes
  which are supported at the moment are SHARED and INTENTION EXCLUSIVE
  and EXCLUSIVE
*/

class MDL_scoped_lock : public MDL_lock
{
private:
  static const bitmap_t m_granted_incompatible[MDL_TYPE_END];
  static const bitmap_t m_waiting_incompatible[MDL_TYPE_END];
};
```

#13. MDL_object_lock

```cpp
/**
  An implementation of a per-object lock. Supports SHARED, SHARED_UPGRADABLE,
  SHARED HIGH PRIORITY and EXCLUSIVE locks.
*/

class MDL_object_lock : public MDL_lock
{
private:
  static const bitmap_t m_granted_incompatible[MDL_TYPE_END];
  static const bitmap_t m_waiting_incompatible[MDL_TYPE_END];

public:
  /** Members for linking the object into the list of unused objects. */
  MDL_object_lock *next_in_cache, **prev_in_cache;
};
```

#14.MDL_object_lock::m_granted_incompatible

```cpp
/**
  Compatibility (or rather "incompatibility") matrices for per-object
  metadata lock. Arrays of bitmaps which elements specify which granted/
  waiting locks are incompatible with type of lock being requested.

  The first array specifies if particular type of request can be satisfied
  if there is granted lock of certain type.

     Request  |  Granted requests for lock       |
      type    | S  SH  SR  SW  SU  SNW  SNRW  X  |
    ----------+----------------------------------+
    S         | +   +   +   +   +   +    +    -  |
    SH        | +   +   +   +   +   +    +    -  |
    SR        | +   +   +   +   +   +    -    -  |
    SW        | +   +   +   +   +   -    -    -  |
    SU        | +   +   +   +   -   -    -    -  |
    SNW       | +   +   +   -   -   -    -    -  |
    SNRW      | +   +   -   -   -   -    -    -  |
    X         | -   -   -   -   -   -    -    -  |
    SU -> X   | -   -   -   -   0   0    0    0  |
    SNW -> X  | -   -   -   0   0   0    0    0  |
    SNRW -> X | -   -   0   0   0   0    0    0  |

  The second array specifies if particular type of request can be satisfied
  if there is waiting request for the same lock of certain type. In other
  words it specifies what is the priority of different lock types.

     Request  |  Pending requests for lock      |
      type    | S  SH  SR  SW  SU  SNW  SNRW  X |
    ----------+---------------------------------+
    S         | +   +   +   +   +   +     +   - |
    SH        | +   +   +   +   +   +     +   + |
    SR        | +   +   +   +   +   +     -   - |
    SW        | +   +   +   +   +   -     -   - |
    SU        | +   +   +   +   +   +     +   - |
    SNW       | +   +   +   +   +   +     +   - |
    SNRW      | +   +   +   +   +   +     +   - |
    X         | +   +   +   +   +   +     +   + |
    SU -> X   | +   +   +   +   +   +     +   + |
    SNW -> X  | +   +   +   +   +   +     +   + |
    SNRW -> X | +   +   +   +   +   +     +   + |

  Here: "+" -- means that request can be satisfied
        "-" -- means that request can't be satisfied and should wait
        "0" -- means impossible situation which will trigger assert

  @note In cases then current context already has "stronger" type
        of lock on the object it will be automatically granted
        thanks to usage of the MDL_context::find_ticket() method.

  @note IX locks are excluded since they are not used for per-object
        metadata locks.
*/
const MDL_lock::bitmap_t
MDL_object_lock::m_granted_incompatible[MDL_TYPE_END] =
{
  0,
  MDL_BIT(MDL_EXCLUSIVE),
  MDL_BIT(MDL_EXCLUSIVE),
  MDL_BIT(MDL_EXCLUSIVE) | MDL_BIT(MDL_SHARED_NO_READ_WRITE),
  MDL_BIT(MDL_EXCLUSIVE) | MDL_BIT(MDL_SHARED_NO_READ_WRITE) |
    MDL_BIT(MDL_SHARED_NO_WRITE),
  MDL_BIT(MDL_EXCLUSIVE) | MDL_BIT(MDL_SHARED_NO_READ_WRITE) |
    MDL_BIT(MDL_SHARED_NO_WRITE) | MDL_BIT(MDL_SHARED_UPGRADABLE),
  MDL_BIT(MDL_EXCLUSIVE) | MDL_BIT(MDL_SHARED_NO_READ_WRITE) |
    MDL_BIT(MDL_SHARED_NO_WRITE) | MDL_BIT(MDL_SHARED_UPGRADABLE) |
    MDL_BIT(MDL_SHARED_WRITE),
  MDL_BIT(MDL_EXCLUSIVE) | MDL_BIT(MDL_SHARED_NO_READ_WRITE) |
    MDL_BIT(MDL_SHARED_NO_WRITE) | MDL_BIT(MDL_SHARED_UPGRADABLE) |
    MDL_BIT(MDL_SHARED_WRITE) | MDL_BIT(MDL_SHARED_READ),
  MDL_BIT(MDL_EXCLUSIVE) | MDL_BIT(MDL_SHARED_NO_READ_WRITE) |
    MDL_BIT(MDL_SHARED_NO_WRITE) | MDL_BIT(MDL_SHARED_UPGRADABLE) |
    MDL_BIT(MDL_SHARED_WRITE) | MDL_BIT(MDL_SHARED_READ) |
    MDL_BIT(MDL_SHARED_HIGH_PRIO) | MDL_BIT(MDL_SHARED)
};


const MDL_lock::bitmap_t
MDL_object_lock::m_waiting_incompatible[MDL_TYPE_END] =
{
  0,
  MDL_BIT(MDL_EXCLUSIVE),
  0,
  MDL_BIT(MDL_EXCLUSIVE) | MDL_BIT(MDL_SHARED_NO_READ_WRITE),
  MDL_BIT(MDL_EXCLUSIVE) | MDL_BIT(MDL_SHARED_NO_READ_WRITE) |
    MDL_BIT(MDL_SHARED_NO_WRITE),
  MDL_BIT(MDL_EXCLUSIVE),
  MDL_BIT(MDL_EXCLUSIVE),
  MDL_BIT(MDL_EXCLUSIVE),
  0
};
```

#15.MDL_scoped_lock::m_granted_incompatible

```cpp
/**
  Compatibility (or rather "incompatibility") matrices for scoped metadata
  lock. Arrays of bitmaps which elements specify which granted/waiting locks
  are incompatible with type of lock being requested.

  The first array specifies if particular type of request can be satisfied
  if there is granted scoped lock of certain type.

             | Type of active   |
     Request |   scoped lock    |
      type   | IS(*)  IX   S  X |
    ---------+------------------+
    IS       |  +      +   +  + |
    IX       |  +      +   -  - |
    S        |  +      -   +  - |
    X        |  +      -   -  - |

  The second array specifies if particular type of request can be satisfied
  if there is already waiting request for the scoped lock of certain type.
  I.e. it specifies what is the priority of different lock types.

             |    Pending      |
     Request |  scoped lock    |
      type   | IS(*)  IX  S  X |
    ---------+-----------------+
    IS       |  +      +  +  + |
    IX       |  +      +  -  - |
    S        |  +      +  +  - |
    X        |  +      +  +  + |

  Here: "+" -- means that request can be satisfied
        "-" -- means that request can't be satisfied and should wait

  (*)  Since intention shared scoped locks are compatible with all other
       type of locks we don't even have any accounting for them.

  Note that relation between scoped locks and objects locks requested
  by statement is not straightforward and is therefore fully defined
  by SQL-layer.
  For example, in order to support global read lock implementation
  SQL-layer acquires IX lock in GLOBAL namespace for each statement
  that can modify metadata or data (i.e. for each statement that
  needs SW, SU, SNW, SNRW or X object locks). OTOH, to ensure that
  DROP DATABASE works correctly with concurrent DDL, IX metadata locks
  in SCHEMA namespace are acquired for DDL statements which can update
  metadata in the schema (i.e. which acquire SU, SNW, SNRW and X locks
  on schema objects) and aren't acquired for DML.
*/

const MDL_lock::bitmap_t MDL_scoped_lock::m_granted_incompatible[MDL_TYPE_END] =
{
  MDL_BIT(MDL_EXCLUSIVE) | MDL_BIT(MDL_SHARED),
  MDL_BIT(MDL_EXCLUSIVE) | MDL_BIT(MDL_INTENTION_EXCLUSIVE), 0, 0, 0, 0, 0, 0,
  MDL_BIT(MDL_EXCLUSIVE) | MDL_BIT(MDL_SHARED) | MDL_BIT(MDL_INTENTION_EXCLUSIVE)
};

const MDL_lock::bitmap_t MDL_scoped_lock::m_waiting_incompatible[MDL_TYPE_END] =
{
  MDL_BIT(MDL_EXCLUSIVE) | MDL_BIT(MDL_SHARED),
  MDL_BIT(MDL_EXCLUSIVE), 0, 0, 0, 0, 0, 0, 0
};
```
