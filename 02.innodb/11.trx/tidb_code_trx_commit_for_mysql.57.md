#1. trx_commit_for_mysql

```cpp
caller:
--innobase_commit_low

trx_commit_for_mysql
--switch (trx->state)
----case TRX_STATE_NOT_STARTED
----case TRX_STATE_FORCED_ROLLBACK:
------trx_start_low(trx, true);
------/* fall through */
----case TRX_STATE_ACTIVE:
----case TRX_STATE_PREPARED:
------trx_commit
--------trx_commit_low
----------trx_commit_in_memory
------------MVCC::view_close
------------trx_roll_savepoints_free
----case TRX_STATE_COMMITTED_IN_MEMORY:
------break;
```

#2.caller

```cpp
很多50多个
- innobase_commit_low//最重要
- dict_create_or_check_foreign_constraint_tables
- dict_create_or_check_sys_virtual

```