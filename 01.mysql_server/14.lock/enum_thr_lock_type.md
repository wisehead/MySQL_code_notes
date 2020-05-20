#1.enum thr_lock_type

```cpp
/*
  Important: if a new lock type is added, a matching lock description
             must be added to sql_test.cc's lock_descriptions array.
*/
enum thr_lock_type { TL_IGNORE=-1,
             TL_UNLOCK,         /* UNLOCK ANY LOCK */
                     /*
                       Parser only! At open_tables() becomes TL_READ or
                       TL_READ_NO_INSERT depending on the binary log format
                       (SBR/RBR) and on the table category (log table).
                       Used for tables that are read by statements which
                       modify tables.
                     */
                     TL_READ_DEFAULT,
             TL_READ,           /* Read lock */
             TL_READ_WITH_SHARED_LOCKS,
             /* High prior. than TL_WRITE. Allow concurrent insert */
             TL_READ_HIGH_PRIORITY,
             /* READ, Don't allow concurrent insert */
             TL_READ_NO_INSERT,
             /*
            Write lock, but allow other threads to read / write.
            Used by BDB tables in MySQL to mark that someone is
            reading/writing to the table.
              */
             TL_WRITE_ALLOW_WRITE,
             /*
               WRITE lock used by concurrent insert. Will allow
               READ, if one could use concurrent insert on table.
             */
             TL_WRITE_CONCURRENT_INSERT,
             /* Write used by INSERT DELAYED.  Allows READ locks */
             TL_WRITE_DELAYED,
                     /*
                       parser only! Late bound low_priority flag.
                       At open_tables() becomes thd->update_lock_default.
                     */
                     TL_WRITE_DEFAULT,
             /* WRITE lock that has lower priority than TL_READ */
             TL_WRITE_LOW_PRIORITY,
             /* Normal WRITE lock */
             TL_WRITE,
             /* Abort new lock request with an error */
             TL_WRITE_ONLY};             
```