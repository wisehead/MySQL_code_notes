#1.Query_cache::pack

```cpp
Query_cache::pack
--try_lock
--while ((++i < iteration_limit) && join_results(join_limit))
----pack_cache
--unlock

```

#2.Query_cache::pack_cache

```cpp
Query_cache::pack_cache
--while (ok && block != first_block)
----Query_cache::move_by_type
```













