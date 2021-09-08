#1.connection

```cpp
0 mysql_execute_command
1 0x0000000000936f40 in mysql_parse
2 0x0000000000920664 in dispatch_command
3 0x000000000091e951 in do_command
4 0x00000000008c2cd4 in do_handle_one_connection
5 0x00000000008c2442 in handle_one_connection
6 0x0000003562e07851 in start_thread () from /lib64/libpthread.so.0
7 0x0000003562ae767d in clone () from /lib64/libc.so.6
```