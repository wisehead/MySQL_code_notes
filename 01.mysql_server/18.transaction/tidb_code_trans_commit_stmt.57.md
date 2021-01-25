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