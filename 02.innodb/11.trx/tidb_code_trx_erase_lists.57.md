#1.trx_erase_lists

```cpp
trx_erase_lists
--
```

#2.caller

```cpp
trx_commit_in_memory
--trx_release_impl_and_expl_locks
----trx_erase_lists
----lock_trx_release_locks
```