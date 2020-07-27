#1. THR_LOCK_DATA

```cpp
struct THR_LOCK_DATA {
  THR_LOCK_INFO *owner{nullptr};
  THR_LOCK_DATA *next{nullptr}, **prev{nullptr};
  THR_LOCK *lock{nullptr};
  mysql_cond_t *cond{nullptr};
  thr_lock_type type{TL_IGNORE};
  void *status_param{nullptr}; /* Param to status functions */
  void *debug_print_param{nullptr};
  struct PSI_table *m_psi{nullptr};
};

```



