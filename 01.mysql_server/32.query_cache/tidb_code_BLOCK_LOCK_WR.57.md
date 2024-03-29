#1.BLOCK_LOCK_WR

```cpp
try_lock and BLOCK_LOCK_UNLOCK
```

#2.insert

```cpp
//跟 Query Result有关，正在填充数据，所以加锁。

insert
--query_block = query_cache_tls->first_query_block
--BLOCK_LOCK_WR(query_block);
--append_result_data
--BLOCK_UNLOCK_WR(query_block)
```

#3.abort
```cpp
//清空Query结果，所以加锁
abort
--try_lock
--Query_cache_block *query_block= query_cache_tls->first_query_block;
--BLOCK_LOCK_WR(query_block);
--free_query(query_block);
----free_query_internal
------query->unlock_n_destroy()
--------this->unlock_writing()
--query_cache_tls->first_query_block= NULL;
--unlock
```

#4.end_of_result

```cpp
end_of_result
--try_lock
--query_block= query_cache_tls->first_query_block
--BLOCK_LOCK_WR(query_block);
--if (last_result_block->length >= query_cache.min_allocation_unit + len)
----query_cache.split_block(last_result_block,len);
--header->found_rows(current_found_rows);
--header->result()->type= Query_cache_block::RESULT;
--header->writer(0);
--query_cache_tls->first_query_block= NULL;
--BLOCK_UNLOCK_WR(query_block);
--unlock
```

#5.resize

```cpp
resize
--lock_and_suspend
--Query_cache_block *block= queries_blocks
--while (block != queries_blocks);
----BLOCK_LOCK_WR(block);
----query->writer()->first_query_block= NULL;
----query->unlock_n_destroy();
--free_cache
--new_query_cache_size= init_cache();
--unlock
```

#6.flush_cache

```cpp

lock_and_suspend
flush_cache
--my_hash_reset(&queries);
--while (queries_blocks != 0)
----BLOCK_LOCK_WR(queries_blocks);
----free_query_internal(queries_blocks);
------query->unlock_n_destroy
unlock
```

#7.invalidate_query_block_list

```cpp
lock()
invalidate_query_block_list
--while (list_root->next != list_root)
----Query_cache_block *query_block= list_root->next->block();
----LOCK_LOCK_WR(query_block);
----free_query(query_block);
------free_query_internal
--------query->unlock_n_destroy()
----------this->unlock_writing()
unlock
```


#8.move_by_type
```cpp
try_lock
move_by_type
--case Query_cache_block::QUERY
----BLOCK_LOCK_WR(block)
----memmove((char*) new_block->table(0), (char*) block->table(0),
----block->query()->unlock_n_destroy();
----new_block->init(len);
----memmove((char*) new_block->data(), data, len - new_block->headers_len());
----Query_cache_query *new_query= ((Query_cache_query *) new_block->data());
----mysql_rwlock_init(key_rwlock_query_cache_query_lock, &new_query->lock);

--case Query_cache_block::RESULT:
----Query_cache_block *query_block= block->result()->parent();
----BLOCK_LOCK_WR(query_block);
----memmove((char*) new_block->data(), data, len - new_block->headers_len());
----BLOCK_UNLOCK_WR(query_block);
unlock
```

#9.join_results

```cpp
try_lock
join_results
--BLOCK_LOCK_WR(block);
--while (result_block != first_result);
----memcpy((char *) write_to,(char*) result_block->result()->data(),len);
----free_memory_block(old_result_block);
--BLOCK_UNLOCK_WR(block);
--unlock
```






