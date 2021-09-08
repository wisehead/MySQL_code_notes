#1.struct worker_thread_t

```cpp
/* Per-thread structure for workers */
struct worker_thread_t
{
  ulonglong event_count; /* number of requests handled by this thread */
  thread_group_t* thread_group;
  worker_thread_t *next_in_list;
  worker_thread_t **prev_in_list;

  mysql_cond_t  cond;
  bool          woken;
};
```