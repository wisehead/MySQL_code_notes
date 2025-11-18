#1. trx_disconnect_from_mysql


```cpp
//XA事务

innodb_replace_trx_in_thd/innobase_close_connection

   trx_disconnect_prepared

      trx_disconnect_from_mysql

           trx->is_recovered = true
```

#2. innodb_replace_trx_in_thd

```cpp
caller:
- detach_native_trx
- reattach_engine_ha_data_to_thd

```

#3. detach_native_trx

```cpp
Sql_cmd_xa_start::execute
--rpl_detach_engine_ha_data
-----Relay_log_info::detach_engine_ha_data
```