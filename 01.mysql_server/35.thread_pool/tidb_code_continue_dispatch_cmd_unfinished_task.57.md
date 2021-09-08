#1.continue_dispatch_cmd_unfinished_task

```cpp
continue_dispatch_cmd_unfinished_task
--thd->update_server_status()
--thd->send_statement_status();
--log_slow_statement(thd);
--thd->reset_query();
--thd->set_command(COM_SLEEP);
--thd_manager->dec_thread_running();
```