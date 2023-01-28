#1.class stats_master

```cpp
  class stats_master
  {
  public:
    stats_master()
    {
      write_lsn= 0;
      log_lsn= 0;
      rpl_bound_lsn= 0;
      log_free_space= 0;
    }

    ~stats_master() {}

    /* Receive lsn update by receive thread */
    ulonglong write_lsn;

    /* Log lsn is current lsn in log sys */
    ulonglong log_lsn;

    /* Recycle lsn update when logs have been applied
       by apply thread or io complete procedure */
    ulonglong rpl_bound_lsn;

    /* Free log space in log sys ring buffer */
    ulonglong log_free_space;
  };
```