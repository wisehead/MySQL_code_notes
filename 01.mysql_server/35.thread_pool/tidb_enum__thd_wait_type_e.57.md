#1.enum _thd_wait_type_e

```cpp
/*
  One should only report wait events that could potentially block for a
  long time. A mutex wait is too short of an event to report. The reason
  is that an event which is reported leads to a new thread starts
  executing a query and this has a negative impact of usage of CPU caches
  and thus the expected gain of starting a new thread must be higher than
  the expected cost of lost performance due to starting a new thread.

  Good examples of events that should be reported are waiting for row locks
  that could easily be for many milliseconds or even seconds and the same
  holds true for global read locks, table locks and other meta data locks.
  Another event of interest is going to sleep for an extended time.

  Note that user-level locks no longer use THD_WAIT_USER_LOCK wait type.
  Since their implementation relies on metadata locks manager it uses
  THD_WAIT_META_DATA_LOCK instead.
*/
typedef enum _thd_wait_type_e {
  THD_WAIT_SLEEP= 1,
  THD_WAIT_DISKIO= 2,
  THD_WAIT_ROW_LOCK= 3,
  THD_WAIT_GLOBAL_LOCK= 4,
  THD_WAIT_META_DATA_LOCK= 5,
  THD_WAIT_TABLE_LOCK= 6,
  THD_WAIT_USER_LOCK= 7,
  THD_WAIT_BINLOG= 8,
  THD_WAIT_GROUP_COMMIT= 9,
  THD_WAIT_SYNC= 10,
  THD_WAIT_NET= 11,
  THD_WAIT_LAST= 12
} thd_wait_type;
```