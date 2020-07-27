#1. THR_LOCK(st_thr_lock)

```cpp
typedef struct st_thr_lock {
  LIST list;
  mysql_mutex_t mutex;
  struct st_lock_list read_wait;
  struct st_lock_list read;
  struct st_lock_list write_wait;
  struct st_lock_list write;
  /* write_lock_count is incremented for write locks and reset on read locks */
  ulong write_lock_count;
  uint read_no_write_count;
  void (*get_status)(void*, int);   /* When one gets a lock */
  void (*copy_status)(void*,void*);
  void (*update_status)(void*);     /* Before release of write */
  void (*restore_status)(void*);         /* Before release of read */
  my_bool (*check_status)(void *);
} THR_LOCK;
```


