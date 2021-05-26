#1.end_of_result

```cpp
end_of_result
--if (thd->killed || thd->is_error())
----abort
--BLOCK_LOCK_WR(query_block);
--if (header->result() == 0)//error，没有插入数据集合
----query_block->query()->state.atomic_set(Query_cache_query::FREEING);
----free_query(query_block,false, 3);
--header->found_rows(current_found_rows);
--header->result()->type= Query_cache_block::RESULT;
--header->writer(0);
--query_cache_tls->first_query_block= NULL;
--BLOCK_UNLOCK_WR(query_block);
```

#2.abort

```cpp
abort
--
```