#1. mysql_lock_tables

```cpp
caller:
--lock_tables

mysql_lock_tables
--lock_tables_check
--get_lock_data//把file->lock返回，file是innodb_handler.
----ha_innobase::store_lock
------check_trx_exists
--------thd_to_trx
----------thd_ha_data
--------innobase_trx_init
------thd_tx_isolation
------thd_in_lock_tables
------thd_sql_command、
--lock_external
----handler::ha_external_lock
------ha_innobase::external_lock
--------ha_innobase::external_lock//todo ........？？？？？？？？
--thr_multi_lock
```

#2.ha_innobase::external_lock//todo