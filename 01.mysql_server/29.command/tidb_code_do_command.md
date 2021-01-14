#1.do_command
```cpp
caller:
--do_handle_one_connection

/**
  Read one command from connection and execute it (query or simple command).
  This function is called in loop from thread function.

  For profiling to work, it must never be called recursively.

  @retval
    0  success
  @retval
    1  request of thread shutdown (see dispatch_command() description)
*/
do_command
--Protocol_classic::get_command
----Protocol_classic::read_packet
------my_net_read
--------net_read_packet
--------net->read_pos = net->buff + net->where_b
------raw_packet= m_thd->net.read_pos;
----command= (enum enum_server_command) (uchar) packet[0];
----Protocol_classic::parse_packet
--dispatch_command
----Global_THD_manager *thd_manager= Global_THD_manager::get_instance();
----thd->set_command(command);
----thd->set_query_id(next_query_id())
```
