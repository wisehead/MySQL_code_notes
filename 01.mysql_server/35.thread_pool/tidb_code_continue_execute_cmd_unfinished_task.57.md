#1.continue_execute_cmd_unfinished_task


```cpp
continue_execute_cmd_unfinished_task
--if (lex->sql_command == SQLCOM_COMMIT || lex->sql_command == SQLCOM_ROLLBACK)
----thd->mdl_context.release_transactional_locks();
----thd->query_plan.set_query_plan;
----trans_commit_stmt
--close_thread_tables
--if (! thd->in_sub_stmt && thd->transaction_rollback_request)
----trans_rollback_implicit
----thd->mdl_context.release_transactional_locks();
--else if (stmt_causes_implicit_commit(thd, CF_IMPLICIT_COMMIT_END))
----trans_commit_implicit
----thd->mdl_context.release_transactional_locks();
--else if (! thd->in_sub_stmt && ! thd->in_multi_stmt_transaction_mode())
----thd->mdl_context.release_transactional_locks()
--else if (! thd->in_sub_stmt)
----thd->mdl_context.release_statement_locks();
--binlog_gtid_end_transaction
```