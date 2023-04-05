#1.trans_commit_stmt

```
trans_commit_stmt
--if (thd->get_transaction()->is_active(Transaction_ctx::STMT))
----res= ha_commit_trans(thd, FALSE);
```