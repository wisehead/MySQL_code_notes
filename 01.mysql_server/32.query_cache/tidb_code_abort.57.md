#1.abort

```cpp
abort
--try_lock
--query_block= query_cache_tls->first_query_block;
--BLOCK_LOCK_WR(query_block);
--free_query
----my_hash_delete(&queries,(uchar *) query_block);
----free_query_internal
--query_cache_tls->first_query_block= NULL;
--unlock

```

#2.caller

```cpp
Query_cache::end_of_result
--if (thd->killed || thd->is_error())
----abort(&thd->query_cache_tls);
```