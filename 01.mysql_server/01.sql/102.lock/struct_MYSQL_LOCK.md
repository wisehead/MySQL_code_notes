#1. MYSQL_LOCK(st_mysql_lock)

```cpp
typedef struct st_mysql_lock
{
  TABLE **table;
  uint table_count,lock_count;
  THR_LOCK_DATA **locks;
} MYSQL_LOCK;

```
