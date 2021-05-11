#1.class MDL_context

```cpp
/**
  Context of the owner of metadata locks. I.e. each server
  connection has such a context.
*/

class MDL_context
{
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
    - LOCK TABLES locks
    - User-level locks
    - HANDLER locks
    - GLOBAL READ LOCK locks
  */

  /**
    Read-write lock protecting m_tickets member.

    @note m_tickets is only manipulated by the owner thread itself,
          but may be read simultaneously by thread querying metadata_locks
          of information_schema.
  */
  mysql_prlock_t m_LOCK_tickets;
  bool destroyed;
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
    Indicates that we need to use DEADLOCK_WEIGHT_DML deadlock
    weight for this context and ignore the deadlock weight provided
    by the MDL_wait_for_subgraph object which we are waiting for.

    @note Can be changed only when there is a guarantee that this
          MDL_context is not waiting for a metadata lock or table
          definition entry.
  */
  bool m_force_dml_deadlock_weight;

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
  /**
    Thread's pins (a.k.a. hazard pointers) to be used by lock-free
    implementation of MDL_map::m_locks container. NULL if pins are
    not yet allocated from container's pinbox.
  */
  LF_PINS *m_pins;
  /**
    State for pseudo random numbers generator (PRNG) which output
    is used to perform random dives into MDL_lock objects hash
    when searching for unused objects to free.
  */
  uint m_rand_state;
};  
```