#1.awake(THD::killed_state state_to_set)

```cpp
THD::awake
--killed= state_to_set;
--ha_kill_connection
----plugin_foreach(thd, kill_handlerton, MYSQL_STORAGE_ENGINE_PLUGIN, 0)
------kill_handlerton
--------innobase_kill_connection
----------trx = thd_to_trx(thd)
----------/* Cancel a pending lock request if there are any */
----------lock_trx_handle_wait
```


#2.timeout sql thread

```cpp
dispatch_command
--mysql_parse
----mysql_execute_command
------THD::send_kill_message
```