#1.trans_commit_stmt

```cpp
caller:
--mysql_execute_command

trans_commit_stmt
--ha_commit_trans
----ha_check_and_coalesce_trx_read_only
----MYSQL_BIN_LOG::commit
------thd_get_cache_mngr
--------thd_get_ha_data(thd, binlog_hton);
------set_prev_position
------ha_commit_low
--------innobase_commit

```
