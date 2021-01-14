#1.THD::send_statement_status

```cpp
THD::send_statement_status
--THD::get_stmt_da
--Diagnostics_area::is_sent
--switch (da->status())
----Protocol_classic::send_ok
------net_send_ok
--------if (protocol->has_client_capability(CLIENT_SESSION_TRACK) thd->session_tracker.enabled_any() && thd->session_tracker.changed_any())
----------server_status |= SERVER_SESSION_STATE_CHANGED;
--------Session_tracker::store
----------Transaction_state_tracker::store
--//end switch

```


#2. send_statement_status for ping command

```cpp
dispatch_command
--Global_THD_manager *thd_manager= Global_THD_manager::get_instance();
--thd->set_command(command);
--thd->set_query_id(next_query_id())
--thd_manager->inc_thread_running()
--switch (command)
----my_ok(thd)
------Diagnostics_area::set_ok_status
--//end switch
--THD::send_statement_status
----switch (da->status())
------Protocol_classic::send_ok
--------net_send_ok
----------my_net_write
------------int3store(buff, static_cast<uint>(len));
------------buff[3]= (uchar) net->pkt_nr++;
------------net_write_buff(net, buff, NET_HEADER_SIZE)//消息头
--------------memcpy(net->write_pos, packet, len)
------------net_write_buff(net,packet,len)
----------net_flush
------------net_write_packet
--------------query_cache_insert
----------------Query_cache::insert
--------------net_write_raw_loop
----------------vio_write
------------------inline_mysql_socket_send
--------------------send(mysql_socket.fd, buf, IF_WIN((int),) n, flags)
----//end switch da->status
```


#3.OK_packet

```cpp
(gdb) x /20xb packet
0x7f30843c52a0: 0x00    0x01    0x00    0x03    0x40    0x00    0x00    0x00
                                 |                        |                                     |
                                 header   |        last_insert_id       warnings(2)
affected_rows  |
               status_flags
0x7f30843c52a8: 0x0b    0x05    0x09    0x08    0x54    0x5f    0x5f    0x5f
                                |                        |             |            |           |           |            |
                                length .   | .      9           8           T .       _ .        _          _
                                              SESSION_TRACK_TRANSACTION_STATE

0x7f30843c52b0: 0x57    0x5f    0x53    0x5f
                                |            |            |           |
                               W .       _           S         _
```