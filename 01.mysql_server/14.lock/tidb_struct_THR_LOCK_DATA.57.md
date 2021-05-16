#1. THR_LOCK_DATA

```cpp
typedef struct st_thr_lock_data {
  THR_LOCK_INFO *owner;
  struct st_thr_lock_data *next,**prev;
  struct st_thr_lock *lock;
  mysql_cond_t *cond;
  enum thr_lock_type type;
  void *status_param;                   /* Param to status functions */
  void *debug_print_param;
  struct PSI_table *m_psi;
} THR_LOCK_DATA;
```



