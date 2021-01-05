#threads
```cpp
1.pxdb_redo_log_scan_thread
2.pxdb_trx_sys_update_thread
3.rio_handler_thread
4.pxdb_log_finish_thread
5.<<DECLARE_THREAD>> DECLARE_THREAD(rio_finish_func)(void * arg);
6.pxdb_master_server_thread
7.pxdb_master_send_thread
8.pxdb_master_receive_thread
9.pxdb_slave_receive_thread
10.pxdb_slave_send_thread
11.pxdb_history_log_thread
12.pxdb_extra_thread

```