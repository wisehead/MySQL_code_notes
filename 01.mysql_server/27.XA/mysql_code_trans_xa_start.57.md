#1.trans_xa_start

```cpp
mysql_execute_command
--Sql_cmd_xa_start::execute
----Sql_cmd_xa_start::trans_xa_start
------XID_STATE *xid_state= thd->get_transaction()->xid_state();

Sql_cmd_xa_start::trans_xa_start
--XID_STATE *xid_state= thd->get_transaction()->xid_state();
--trans_begin
----trans_check_state
----Locked_tables_list::unlock_locked_tables
----if (thd->in_multi_stmt_transaction_mode() ||(thd->variables.option_bits & OPTION_TABLE_LOCK))
------ha_commit_trans(thd, TRUE)//隐式提交之前没有commit的事务。
----thd->variables.option_bits&= ~OPTION_BEGIN;
----thd->get_transaction()->reset_unsafe_rollback_flags(Transaction_ctx::SESSION)
----thd->mdl_context.release_transactional_locks
------release_locks_stored_before(MDL_STATEMENT, NULL);
------release_locks_stored_before(MDL_TRANSACTION, NULL);
----thd->variables.option_bits|= OPTION_BEGIN;//正式开始，之前是善后，准备逻辑
----thd->server_status|= SERVER_STATUS_IN_TRANS;
----inline_mysql_start_transaction//to be deep dive later.
----gtid_set_performance_schema_values
--xid_state->start_normal_xa(m_xid);
```