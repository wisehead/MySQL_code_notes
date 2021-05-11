#1.class MDL_map

```cpp
//mdl_map使用hash表，保存了MySQL所有的mdl_lock，全局共享，使用MDL_KEY作为key来表，key=【db_name+table_name】唯一定位一个表。

/**
  A collection of all MDL locks. A singleton,
  there is only one instance of the map in the server.
*/

class MDL_map
{
private:
  /** LF_HASH with all locks in the server. */
  LF_HASH m_locks;
  /** Pre-allocated MDL_lock object for GLOBAL namespace. */
  MDL_lock *m_global_lock;
  /** Pre-allocated MDL_lock object for COMMIT namespace. */
  MDL_lock *m_commit_lock;
  /**
    Number of unused MDL_lock objects in the server.

    Updated using atomic operations, read using both atomic and ordinary
    reads. We assume that ordinary reads of 32-bit words can't result in
    partial results, but may produce stale results thanks to memory
    reordering, LF_HASH seems to be using similar assumption.

    Note that due to fact that updates to this counter are not atomic with
    marking MDL_lock objects as used/unused it might easily get negative
    for some short period of time. Code which uses its value needs to take
    this into account.
  */
  volatile int32 m_unused_lock_objects;

  /** Pre-allocated MDL_lock object for BACKUP namespace. */
  MDL_lock *m_backup_lock;
  /** Pre-allocated MDL_lock object for BINLOG namespace */
  MDL_lock *m_binlog_lock;
};

```