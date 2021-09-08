#1.handle_event

```cpp

handle_event
--if (!connection->logged_in)
----threadpool_add_connection
--else
----connection->thd->tp_connection = (void*) connection;
----threadpool_process_request
----if (thd_need_callback(connection->thd))
------thd_lock_data(connection->thd);
------if (connection->thd->sync_status == ENGINE_LOG_SYNC_FINISHED)
--------my_thread_set_THR_THD(connection->thd);
--------continue_execute_cmd_unfinished_task
--------if (connection->thd->server_command == COM_STMT_EXECUTE)
----------continue_unfinished_pst_cmd
--------continue_dispatch_cmd_unfinished_task
--------continue_threadpool_unfinished_task
------else
--------connection->thd->is_running = false;
--set_wait_timeout
--start_io
```