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

#3. trx_flush_log_if_needed_low

```cpp
caller:
- trx_flush_log_if_needed


trx_flush_log_if_needed_low
--if (async_commit && flush)
----log_write_up_to(lsn, true, (void*)trx->mysql_thd))
```

#4. trx_flush_log_if_needed

```cpp
caller:
- trx_commit_in_memory
- trx_commit_complete_for_mysql

trx_flush_log_if_needed
--trx_flush_log_if_needed_low(lsn, trx, async_commit);
```

#5. trx_commit_in_memory

```cpp
caller:
trx_commit_low
--trx_commit_in_memory(trx, mtr, serialised, trx_need_async_commit(trx));

trx_commit_in_memory
--if (mtr != NULL)
----trx_flush_log_if_needed(lsn, trx, async_commit);
```

#6.trx_commit_complete_for_mysql

```cpp
caller:
- innobase_commit

trx_commit_complete_for_mysql
--trx_flush_log_if_needed(trx->commit_lsn, trx, trx_need_async_commit(trx))
```