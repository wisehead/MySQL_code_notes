#1.row_mysql_handle_errors

```cpp
row_mysql_handle_errors
--switch (err)
----case DB_LOCK_WAIT:
------trx_kill_blocking
------lock_wait_suspend_thread(thr);
```