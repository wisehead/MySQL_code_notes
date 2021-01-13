#1.async_commit

```cpp
- log_write_up_to
- trx_flush_log_if_needed_low
- trx_flush_log_if_needed
- trx_commit_in_memory
```

#2. log_write_up_to

```cpp
caller:
- trx_flush_log_if_needed_low


log_write_up_to
--async_commit = (m1 != NULL);
--if (async_commit)
----log.wait_queue->reserve(lsn, m1, ts)
----log_wait_for_flush(log, lsn, true);
----ncdb_stats.n_async_commit++;
```