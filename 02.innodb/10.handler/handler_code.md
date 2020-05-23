#1. innobase_commit

```cpp
caller:
--ha_commit_low

/*****************************************************************//**
Commits a transaction in an InnoDB database or marks an SQL statement
ended.
@return 0 */

innobase_commit
--check_trx_exists
--thd_binlog_pos
----get_trans_pos
--trx->mysql_log_offset= static_cast<ib_int64_t>(pos);
--innobase_commit_low
----trx_commit_for_mysql
------trx_commit
--------trx_commit_low
----------trx_commit_in_memory
------------MVCC::view_close
------------trx_roll_savepoints_free
--trx_commit_complete_for_mysql
--innobase_srv_conc_force_exit_innodb
----srv_conc_force_exit_innodb
------srv_conc_exit_innodb_with_atomics
```
