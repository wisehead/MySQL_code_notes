#1.BLOCK_LOCK_WR

```cpp

```

#2.insert

```cpp
insert
--query_block = query_cache_tls->first_query_block
--BLOCK_LOCK_WR(query_block);
--append_result_data
--BLOCK_UNLOCK_WR(query_block)
```

#3.abort
```cpp
abort
--try_lock
--Query_cache_block *query_block= query_cache_tls->first_query_block;
--BLOCK_LOCK_WR(query_block);
--free_query(query_block);
----//..... BLOCK_UNLOCK_WR
--query_cache_tls->first_query_block= NULL;
--unlock
```

#4.end_of_result

```cpp
end_of_result
--try_lock
--query_block= query_cache_tls->first_query_block
--BLOCK_LOCK_WR(query_block);
--header->found_rows(current_found_rows);
--header->result()->type= Query_cache_block::RESULT;
--header->writer(0);
--query_cache_tls->first_query_block= NULL;
--BLOCK_UNLOCK_WR(query_block);
--unlock
```