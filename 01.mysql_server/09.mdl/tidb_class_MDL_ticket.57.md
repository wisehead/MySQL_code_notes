#1.class MDL_ticket

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

  /**
    Indicates that ticket corresponds to lock acquired using "fast path"
    algorithm. Particularly this means that it was not included into
    MDL_lock::m_granted bitmap/list and instead is accounted for by
    MDL_lock::m_fast_path_locks_granted_counter
  */
  bool m_is_fast_path;

  /**
    Indicates that ticket corresponds to lock request which required
    storage engine notification during its acquisition and requires
    storage engine notification after its release.
  */
  bool m_hton_notified;

  PSI_metadata_lock *m_psi;
};
  
```
