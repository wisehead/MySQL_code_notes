#1.class Master_info

```cpp
/*****************************************************************************
  Replication IO Thread

  Master_info contains:
    - information about how to connect to a master
    - current master log name
    - current master log offset
    - misc control variables

  Master_info is initialized once from the master.info repository if such
  exists. Otherwise, data members corresponding to master.info fields
  are initialized with defaults specified by master-* options. The
  initialization is done through mi_init_info() call.

  Logically, the format of master.info repository is presented as follows:

  log_name
  log_pos
  master_host
  master_user
  master_pass
  master_port
  master_connect_retry

  To write out the contents of master.info to disk a call to flush_info()
  is required. Currently, it is needed every time we read and queue data
  from the master.

  To clean up, call end_info()

*****************************************************************************/

class Master_info : public Rpl_info
{
public:
  /**
    Host name or ip address stored in the master.info.
  */
  char host[HOSTNAME_LENGTH + 1];

private:
  /**
    If true, USER/PASSWORD was specified when running START SLAVE.
  */
  bool start_user_configured;
  /**
    User's name stored in the master.info.
  */
  char user[USERNAME_LENGTH + 1];
  /**
    User's password stored in the master.info.
  */
  char password[MAX_PASSWORD_LENGTH + 1];
  /**
    User specified when running START SLAVE.
  */
  char start_user[USERNAME_LENGTH + 1];
  /**
    Password specified when running START SLAVE.
  */
  char start_password[MAX_PASSWORD_LENGTH + 1];
  /**
    Stores the autentication plugin specified when running START SLAVE.
  */
  char start_plugin_auth[FN_REFLEN + 1];
  /**
    Stores the autentication plugin directory specified when running
    START SLAVE.
  */
  char start_plugin_dir[FN_REFLEN + 1];

public:
  my_bool ssl; // enables use of SSL connection if true
  char ssl_ca[FN_REFLEN], ssl_capath[FN_REFLEN], ssl_cert[FN_REFLEN];
  char ssl_cipher[FN_REFLEN], ssl_key[FN_REFLEN];
  char ssl_crl[FN_REFLEN], ssl_crlpath[FN_REFLEN];
  my_bool ssl_verify_server_cert;

  MYSQL* mysql;
  uint32 file_id;               /* for 3.23 load data infile */
  Relay_log_info *rli;
  uint port;
  uint connect_retry;
  /*
     The difference in seconds between the clock of the master and the clock of
     the slave (second - first). It must be signed as it may be <0 or >0.
     clock_diff_with_master is computed when the I/O thread starts; for this the
     I/O thread does a SELECT UNIX_TIMESTAMP() on the master.
     "how late the slave is compared to the master" is computed like this:
     clock_of_slave - last_timestamp_executed_by_SQL_thread - clock_diff_with_master

  */
  long clock_diff_with_master;
  float heartbeat_period;         // interface with CHANGE MASTER or master.info
  ulonglong received_heartbeats;  // counter of received heartbeat events

  time_t last_heartbeat;

  Dynamic_ids *ignore_server_ids;

  ulong master_id;
  /*
    to hold checksum alg in use until IO thread has received FD.
    Initialized to novalue, then set to the queried from master
    @@global.binlog_checksum and deactivated once FD has been received.
  */
  uint8 checksum_alg_before_fd;
  ulong retry_count;
  char master_uuid[UUID_LENGTH+1];
  char bind_addr[HOSTNAME_LENGTH+1];

  ulong master_gtid_mode;

protected:
  char master_log_name[FN_REFLEN];
  my_off_t master_log_pos;
  /**
   * Stores semi-sync group name
   */
  char _semi_sync_group_name[FN_REFLEN];  
  
private:
  bool auto_position;
};

```