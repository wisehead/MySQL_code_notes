#threads
```cpp
1.tidb_redo_log_scan_thread
2.tidb_trx_sys_update_thread
3.rio_handler_thread
4.tidb_log_finish_thread
5.<<DECLARE_THREAD>> DECLARE_THREAD(rio_finish_func)(void * arg);
6.tidb_master_server_thread
7.tidb_master_send_thread
8.tidb_master_receive_thread
9.tidb_slave_receive_thread
10.tidb_slave_send_thread
11.tidb_history_log_thread
12.tidb_extra_thread

```