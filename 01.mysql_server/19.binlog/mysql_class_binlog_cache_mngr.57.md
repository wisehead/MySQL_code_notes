#1.class binlog_cache_mngr

```cpp
class binlog_cache_mngr {
  binlog_stmt_cache_data stmt_cache;
  binlog_trx_cache_data trx_cache;
  /*
    The bool flag is for preventing do_binlog_xa_commit_rollback()
    execution twice which can happen for "external" xa commit/rollback.
  */
  bool has_logged_xid;
};
```