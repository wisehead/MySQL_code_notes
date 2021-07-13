#1.send_ok packet


```
(gdb) x /20xb packet
0x7f30843c52a0: 0x00    0x01    0x00    0x03    0x40    0x00    0x00    0x00
                 |                |                      |
                 header(1)|       last_insert_id(1)      warnings(2)
                        affected_rows(1)  |
                                         status_flags(2)
                                         
0x7f30843c52a8: 0x0b    0x05    0x09    0x08    0x54    0x5f    0x5f    0x5f
                |                |        |       |       |      |        |
                length   |       9        8       T       _      _        _
                         SESSION_TRACK_TRANSACTION_STATE

0x7f30843c52b0: 0x57    0x5f    0x53    0x5f
                |        |        |       |
                W        _        S       _
                               
                               
```

#2.stack

```
6.net_send_ok断点
(gdb) bt
#0  my_net_write (net=0x7f2e3eddcba0, packet=0x7f30843c52a0 "", len=20) at /home/chenhui/txsql-ncdb/sql/net_serv.cc:284
#1  0x000000000153422b in net_send_ok (thd=0x7f2e3eddb000, server_status=16387, statement_warn_count=0, affected_rows=1, id=0, message=0x7f2e3edde098 "", eof_identifier=false) at /home/chenhui/txsql-ncdb/sql/protocol_classic.cc:367
#2  0x00000000015349e3 in Protocol_classic::send_ok (this=0x7f2e3eddc3a0, server_status=3, statement_warn_count=0, affected_rows=1, last_insert_id=0, message=0x7f2e3edde098 "") at /home/chenhui/txsql-ncdb/sql/protocol_classic.cc:643
#3  0x00000000015b42ea in THD::send_statement_status (this=0x7f2e3eddb000) at /home/chenhui/txsql-ncdb/sql/sql_class.cc:4821
#4  0x000000000160c37e in dispatch_command (thd=0x7f2e3eddb000, com_data=0x7f308acf8450, command=COM_QUERY) at /home/chenhui/txsql-ncdb/sql/sql_parse.cc:2075
#5  0x000000000160964d in do_command (thd=0x7f2e3eddb000) at /home/chenhui/txsql-ncdb/sql/sql_parse.cc:1074
#6  0x0000000001717fae in threadpool_process_request (thd=0x7f2e3eddb000) at /home/chenhui/txsql-ncdb/sql/threadpool_common.cc:275
#7  0x000000000171b27d in handle_event (connection=0x7f30c5e48ae0) at /home/chenhui/txsql-ncdb/sql/threadpool_unix.cc:1605
#8  0x000000000171b4bf in worker_main (param=0x2fae000 <all_groups+2048>) at /home/chenhui/txsql-ncdb/sql/threadpool_unix.cc:1677
#9  0x00000000019fefab in pfs_spawn_thread (arg=0x7f30c2404020) at /home/chenhui/txsql-ncdb/storage/perfschema/pfs.cc:2188
#10 0x00007f30c790eea5 in start_thread () from /lib64/libpthread.so.0
#11 0x00007f30c65d296d in clone () from /lib64/libc.so.6
```