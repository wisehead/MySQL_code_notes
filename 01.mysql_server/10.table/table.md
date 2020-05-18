#1.open_and_lock_tables
```cpp
/**
  Open all tables in list, locks them and optionally process derived tables.

  @param thd              Thread context.
  @param tables               List of tables for open and locking.
  @param derived              If to handle derived tables.
  @param flags                Bitmap of options to be used to open and lock
                              tables (see open_tables() and mysql_lock_tables()
                              for details).
  @param prelocking_strategy  Strategy which specifies how prelocking algorithm
                              should work for this statement.

  @note
    The thr_lock locks will automatically be freed by
    close_thread_tables().

  @retval FALSE  OK.
  @retval TRUE   Error
*/

open_and_lock_tables
--open_tables
```

#2. open_tables

```cpp
open_tables
--lock_table_names
----mdl_requests.push_front(&table->mdl_request);
----MDL_context::acquire_locks
```
