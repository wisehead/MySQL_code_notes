#1.class Binlog_sender

```cpp
/**
  The major logic of dump thread is implemented in this class. It sends
  required binlog events to clients according to their requests.
*/
class Binlog_sender
{
public:

  /**
    It checks the dump reqest and sends events to the client until it finish
    all events(for mysqlbinlog) or encounters an error.
  */
  void run();
private:
  THD *m_thd;
  String& m_packet;

  /* Requested start binlog file and position */
  const char *m_start_file;
  my_off_t m_start_pos;

  /*
    For COM_BINLOG_DUMP_GTID, It may include a GTID set. All events in the set
    should not be sent to the client.
  */
  Gtid_set *m_exclude_gtid;
  bool m_using_gtid_protocol;
  bool m_check_previous_gtid_event;
  bool m_gtid_clear_fd_created_flag;

  /* The binlog file it is reading */
  LOG_INFO m_linfo;

  binary_log::enum_binlog_checksum_alg m_event_checksum_alg;
  binary_log::enum_binlog_checksum_alg m_slave_checksum_alg;
  ulonglong m_heartbeat_period;
  time_t m_last_event_sent_ts;

  /*
    For mysqlbinlog(server_id is 0), it will stop immediately without waiting
    if it already reads all events.
  */
  bool m_wait_new_events;

  Diagnostics_area m_diag_area;
  char m_errmsg_buf[MYSQL_ERRMSG_SIZE];
  const char *m_errmsg;
  int m_errno;
  /*
    The position of the event it reads most recently is stored. So it can report
    the exact position after where an error happens.

    m_last_file will point to m_info.log_file_name, if it is same to
    m_info.log_file_name. Otherwise the file name is copied to m_last_file_buf
    and m_last_file will point to it.
  */
  char m_last_file_buf[FN_REFLEN];
  const char *m_last_file;
  my_off_t m_last_pos;

  /*
    Needed to be able to evaluate if buffer needs to be resized (shrunk).
  */
  ushort m_half_buffer_size_req_counter;

  /*
   * The size of the buffer next time we shrink it.
   * This variable is updated once everytime we shrink or grow the buffer.
   */
  size_t m_new_shrink_size;

  /*
     Max size of the buffer is 4GB (UINT_MAX32). It is UINT_MAX32 since the
     threshold is set to (@c Log_event::read_log_event):

       max(max_allowed_packet,
           opt_binlog_rows_event_max_size + MAX_LOG_EVENT_HEADER)

     - opt_binlog_rows_event_max_size is defined as an unsigned long,
       thence in theory row events can be bigger than UINT_MAX32.

     - max_allowed_packet is set to MAX_MAX_ALLOWED_PACKET which is in
       turn defined as 1GB (i.e., 1024*1024*1024). (@c Binlog_sender::init()).

     Therefore, anything bigger than UINT_MAX32 is not loadable into the
     packet, thus we set the limit to 4GB (which is the value for UINT_MAX32,
     @c PACKET_MAXIMUM_SIZE).

   */
  const static uint32 PACKET_MAX_SIZE;

  /*
   * After these consecutive times using less than half of the buffer
   * the buffer is shrunk.
   */
  const static ushort PACKET_SHRINK_COUNTER_THRESHOLD;

  /**
   * The minimum size of the buffer.
   */
  const static uint32 PACKET_MIN_SIZE;

  /**
   * How much to grow the buffer each time we need to accommodate more bytes
   * than it currently can hold.
   */
  const static float PACKET_GROW_FACTOR;
  /**
   * The dual of PACKET_GROW_FACTOR. How much to shrink the buffer each time
   * it is deemed to being underused.
   */
  const static float PACKET_SHRINK_FACTOR;

  uint32 m_flag;
  /*
    It is true if any plugin requires to observe the transmission for each event.
    And HOOKs(reserve_header, before_send and after_send) are called when
    transmitting each event. Otherwise, it is false and HOOKs are not called.
  */
  bool m_observe_transmission;

  /* It is true if transmit_start hook is called. If the hook is not called
   * it will be false.
   */
  bool m_transmit_started;
  /*
    It initializes the context, checks if the dump request is valid and
    if binlog status is correct.
  */  

};
```