#1.class stats_base

```cpp
  class stats_base
  {
  public:
    stats_base()
    {
      clear_error_info();
      recycle_lsn= 0;
      vdl= 0;
      trx_purge_no= 0;
      rpl_free_space= 0;
    }

    ~stats_base() {}

    /* Error number reported by IO or apply thread*/
    ulonglong last_errno;

    /* Last Error Timestamp */
    char last_err_tm[32];

    /* Error message reported by IO or apply thread */
    char last_err_msg[CONNECT_STRING_MAXLEN];

    /* Recycle lsn update when logs have been applied
       by apply thread or io complete procedure.
       Master: Oldest lsn in each slave */
    ulonglong recycle_lsn;

    /* Volumn Duration Lsn get by master from cbs */
    ulonglong vdl;

    /* Trx purge number sent to master */
    ulonglong trx_purge_no;

    /* Free space in replication ring buffer */
    ulonglong rpl_free_space;

  };
  
```