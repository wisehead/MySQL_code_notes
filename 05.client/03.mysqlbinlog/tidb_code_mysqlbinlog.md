#1.mysqlbinlog client side

```cpp
main
--load_defaults
--parse_args
----handle_options
--gtid_client_init
--dump_multiple_logs
----dump_single_log
------dump_remote_log_entries
--------safe_connect
--------if (to_last_remote_log && stop_never)
----------server_id= 1;
--------if (opt_remote_proto == BINLOG_DUMP_NON_GTID)
----------command= COM_BINLOG_DUMP
----------int4store(ptr_buffer, (uint32) start_position);
----------int2store(ptr_buffer, get_dump_flags());
----------int4store(ptr_buffer, server_id);
----------memcpy(ptr_buffer, logname, BINLOG_NAME_INFO_SIZE);
----------simple_command(mysql, command, command_buffer, command_size, 1)
--------for(1)//一直for循环，hang在这里
----------cli_safe_read
------------cli_safe_read_with_ok
----------type= (Log_event_type) net->read_pos[1 + EVENT_TYPE_OFFSET];
----------Log_event::read_log_event
----------ev->register_temp_buf((char *) net->read_pos + 1)
----------process_event(print_event_info, ev, old_off, logname)
--------//end for(1)

```

#2.server side
```cpp
do_command
--//command 1:COM_QUERY, SELECT VERSION()
--//command 2: COM_QUERY, SET @master_binlog_checksum='NONE'
--//command 3:COM_BINLOG_DUMP
--dispatch_command
----com_binlog_dump
------mysql_binlog_send
--------Binlog_sender::run
----------Binlog_sender::send_binlog
-=----------Binlog_sender::send_format_description_event
--------------read_event
------------start_pos= my_b_tell(log_cache);
------------end_pos= get_binlog_end_pos(log_cache);//hang here
--------------Binlog_sender::wait_new_events
----------------wait_without_heartbeat
------------------MYSQL_BIN_LOG::wait_for_update_bin_log
--------------------mysql_cond_wait(&update_cond, &LOCK_binlog_end_pos);
------------Binlog_sender::send_events
--------------Binlog_sender::send_packet
----------------my_net_write
------------------int3store(buff, static_cast<uint>(len));
------------------buff[3]= (uchar) net->pkt_nr++;
------------------net_write_buff(net, buff, NET_HEADER_SIZE)
------------------net_write_buff(net,packet,len)
```

#3.update_cond

```cpp
caller:
- MYSQL_BIN_LOG::open_binlog
- MYSQL_BIN_LOG::write_incident
- MYSQL_BIN_LOG::commit
- MYSQL_BIN_LOG::ordered_commit


--update_binlog_end_pos
----signal_update
```