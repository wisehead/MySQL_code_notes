#1.thread_pool 建立连接的堆栈如下：

```cpp
mysqld_main
handle_connections_sockets
create_new_thread
tp_add_connection
queue_put
thread group中的 worker 处理请求的堆栈如下：

0 mysql_execute_command
1 0x0000000000936f40 in mysql_parse
2 0x0000000000920664 in dispatch_command
3 0x000000000091e951 in do_command
4 0x0000000000a78533 in threadpool_process_request
5 0x000000000066a10b in handle_event
6 0x000000000066a436 in worker_main
7 0x0000003562e07851 in start_thread ()
8 0x0000003562ae767d in clone ()
```