#1.struct THR_LOCK_INFO

```cpp
/*
  A description of the thread which owns the lock. The address
  of an instance of this structure is used to uniquely identify the thread.
*/

typedef struct st_thr_lock_info
{
  my_thread_id thread_id;
  mysql_cond_t *suspend;
} THR_LOCK_INFO;
```