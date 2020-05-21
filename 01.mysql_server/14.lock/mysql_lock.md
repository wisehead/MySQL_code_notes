#1. mysql_lock_tables

```cpp
caller:
--lock_tables

mysql_lock_tables
--lock_tables_check
--get_lock_data
----ha_innobase::store_lock
------check_trx_exists
--------thd_to_trx
----------thd_ha_data
--------innobase_trx_init
------thd_tx_isolation
------thd_in_lock_tables
------thd_sql_command
```