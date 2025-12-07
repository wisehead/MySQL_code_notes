#1.innobase_commit_low

```cpp
innobase_commit_low(trx)
    -> trx_commit_for_mysql()
        -> trx_commit(trx)
            -> trx_commit_low()
                 ->  trx_commit_in_memory()
                     -> lock_trx_release_locks()

```