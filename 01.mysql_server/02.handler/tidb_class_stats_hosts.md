#1.class stats_hosts

```cpp
  class stats_hosts
  {
  public:
    stats_hosts()
    {
      node_id= 0;
      active = 0;
      extra_active = 0;
      port= 0;
      rpl_lsn= 0;
      recycle_lsn= 0;
      applied_lsn= 0;
      trx_purge_no= 0;
      rpl_lag= 0;
      false_lag= 0;
      space_alloc = 0;
      space_used = 0;
      host[0]= '\0';
    }

    ~stats_hosts() {}

    /* Slave node id*/
    ulonglong node_id;

    /* Slave host name, ip */
    char host[HOSTNAME_LENGTH];

    /* Slave is active */
    ulonglong active;

    /* Extra node is active */
    ulonglong extra_active;

    /* Slave node port*/
    ulonglong port;

    /* Replication-started lsn to each slave */
    ulonglong rpl_lsn;

    /* Applied lsn sent by each slave */
    ulonglong applied_lsn;

    /* Recycle lsn sent by each slave */
    ulonglong recycle_lsn;

    /* Trx purge number sent by each slave */
    ulonglong trx_purge_no;

    /* Log lag in microsecond */
    ulonglong rpl_lag;

    /* The number of the false lag */
    ulonglong false_lag;

    /* The size of space allocated */
    ulonglong space_alloc;

    /* The size of space used */
    ulonglong space_used;
  };
  
```