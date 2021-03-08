#1.trans_commit_stmt

```cpp
/**
  Commit the single statement transaction.

  @note Note that if the autocommit is on, then the following call
        inside InnoDB will commit or rollback the whole transaction
        (= the statement). The autocommit mechanism built into InnoDB
        is based on counting locks, but if the user has used LOCK
        TABLES then that mechanism does not know to do the commit.

  @param thd     Current thread

  @retval FALSE  Success
  @retval TRUE   Failure
*/

trans_commit_stmt
--if (thd->get_transaction()->is_active(Transaction_ctx::STMT))
----ha_commit_trans
----if (! thd->in_active_multi_stmt_transaction())
------trans_reset_one_shot_chistics
```


#2. trans_commit_stmt redo log flow for insert

```cpp

trans_commit_stmt
--ha_commit_trans
----ha_prepare_low
------innobase_xa_prepare
--------trx_prepare_for_mysql
----------trx_prepare
------------trx_prepare_low
--------------trx_undo_set_state_at_prepare
----------------mlog_write_ulint//MLOG_2BYTES
----------------mlog_write_ulint//MLOG_1BYTE
--------------trx_undo_write_xid
----------------mlog_write_ulint//MLOG_4BYTES
----------------mlog_write_string//MLOG_WRITE_STRING
--------------mtr_t::commit
----MYSQL_BIN_LOG::commit
------MYSQL_BIN_LOG::ordered_commit
--------MYSQL_BIN_LOG::process_commit_stage_queue
----------ha_commit_low
------------innobase_commit
--------------innobase_commit_low
----------------trx_commit_for_mysql
------------------trx_commit
--------------------trx_commit_low
----------------------trx_write_serialisation_history
------------------------trx_undo_set_state_at_finish
--------------------------mlog_write_ulint//MLOG_2BYTES
------------------------trx_undo_update_cleanup
--------------------------trx_purge_add_update_undo_to_history
----------------------------flst_add_first
------------------------------flst_add_to_empty
--------------------------------flst_write_addr
----------------------------------mlog_write_ulint//MLOG_4BYTES
--------------------------------mlog_write_ulint//MLOG_4BYTES
----------------------------mlog_write_ull//MLOG_8BYTES， which is trx->no
----------------------------trx_sys_update_mysql_binlog_offset
------------------------------mlog_write_ulint//MLOG_4BYTES
----------------------trx_write_commit_log//MLOG_TRX_COMMIT
----------------------mtr_t::commit
```























