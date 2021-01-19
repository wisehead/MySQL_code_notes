#1.mysqlbinlog

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