#1.free_old_query

```cpp
free_old_query
--while ((block=block->next) != queries_blocks )
----if (header->result() != 0 && header->result()->type == Query_cache_block::RESULT && block->query()->try_lock_writing())
------query_block = block;
------break
--free_query
```