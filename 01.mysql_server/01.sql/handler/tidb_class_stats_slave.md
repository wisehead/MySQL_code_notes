#1.class stats_slave

```cpp
  class stats_slave
  {
  public:
    stats_slave()
    {
      io_active= false;
      extra_active = false;
      master_host[0]= '\0';
      master_info_file[0]= '\0';
      master_port= 0;
      rpl_port= 0;
      reconn_interval= 1;
      received_lsn= 0;
      parse_lsn= 0;
      apply_lsn= 0;
      slave_lag= 0;
      slave_rtt = 0;
      conn_count= 0;
      master_shift_count= 0;
      false_lag= 0;
    }

    ~stats_slave() {}

    /* Slave io state*/
    bool io_active;

    /* Extra state*/
    bool extra_active;

    /* Master host name, ip */
    char master_host[64];

    /* Master node port */
    ulonglong master_port;
    /* Master slave replication port */
    ulonglong rpl_port;

    /* Reconnection interval */
    ulonglong reconn_interval;

    /* Receive lsn update by receive thread*/
    ulonglong received_lsn;

    /* Parse lsn update by applied thread */
    ulonglong parse_lsn;

    /* Apply lsn update when logs are applied by apply thread */
    ulonglong apply_lsn;

    /* The microseconds behind the master */
    ulonglong slave_lag;

    /* The rtt of the network */
    ulonglong slave_rtt;

    /* The file to store replication information */
    char master_info_file[CONNECT_STRING_MAXLEN];

    /* The number of the slave tries to connect the master */
    ulonglong conn_count;

    /* The number of the master shifts */
    ulonglong master_shift_count;

    /* The number of the false lag */
    ulonglong false_lag;
  };
      
```