#1.class MDL_lock

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
  /** The key of the object (data) being protected. */
  MDL_key key;
  
  mysql_prlock_t m_rwlock;  
  /** List of granted tickets for this lock. */
  Ticket_list m_granted;
  /** Tickets for contexts waiting to acquire a lock. */
  Ticket_list m_waiting;

private:
  /**
    Number of times high priority, "hog" lock requests (X, SNRW, SNW) have been
    granted while lower priority lock requests (all other types) were waiting.
    Currently used only for object locks. Protected by m_rwlock lock.
  */
  ulong m_hog_lock_count;
  /**
    Number of times high priority, "piglet" lock requests (SW) have been
    granted while locks requests with lower priority (SRO) were waiting.
    Currently used only for object locks. Protected by m_rwlock lock.
  */
  ulong m_piglet_lock_count;
  /**
    Index of one of the MDL_lock_strategy::m_waiting_incompatible
    arrays which represents the current priority matrice.
  */
  uint m_current_waiting_incompatible_idx;
public:
  /**
    Number of granted or waiting lock requests of "obtrusive" type.
    Also includes "obtrusive" lock requests for which we about to check
    if they can be granted.


    @sa MDL_lock::get_unobtrusive_lock_increment() description.

    @note This number doesn't include "unobtrusive" locks which were acquired
          using "slow path".
  */
  uint m_obtrusive_locks_granted_waiting_count;
  /**
    Combination of IS_DESTROYED/HAS_OBTRUSIVE/HAS_SLOW_PATH flags and packed
    counters of specific types of "unobtrusive" locks which were granted using
    "fast path".

    @sa MDL_scoped_lock::m_unobtrusive_lock_increment and
        MDL_object_lock::m_unobtrusive_lock_increment for details about how
        counts of different types of locks are packed into this field.

    @note Doesn't include "unobtrusive" locks granted using "slow path".

    @note We use combination of atomic operations and protection by
          MDL_lock::m_rwlock lock to work with this member:

          * Write and Read-Modify-Write operations are always carried out
            atomically. This is necessary to avoid lost updates on 32-bit
            platforms among other things.
          * In some cases Reads can be done non-atomically because we don't
            really care about value which they will return (for example,
            if further down the line there will be an atomic compare-and-swap
            operation, which will validate this value and provide the correct
            value if the validation will fail).
          * In other cases Reads can be done non-atomically since they happen
            under protection of MDL_lock::m_rwlock and there is some invariant
            which ensures that concurrent updates of the m_fast_path_state
            member can't happen while  MDL_lock::m_rwlock is held
            (@sa IS_DESTROYED, HAS_OBTRUSIVE, HAS_SLOW_PATH).

    @note IMPORTANT!!!
          In order to enforce the above rules and other invariants,
          MDL_lock::m_fast_path_state should not be updated directly.
          Use fast_path_state_cas()/add()/reset() wrapper methods instead.

    @note Needs to be volatile in order to be compatible with our
          my_atomic_*() API.
  */
  volatile fast_path_state_t m_fast_path_state;
  
  static const MDL_lock_strategy m_scoped_lock_strategy;
  static const MDL_lock_strategy m_object_lock_strategy;
};        
```