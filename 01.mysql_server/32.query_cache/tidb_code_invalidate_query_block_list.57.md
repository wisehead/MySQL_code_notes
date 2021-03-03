#1.invalidate_query_block_list

```cpp
invalidate_query_block_list
--while (list_root->next != list_root)
----query_block= list_root->next->block()
----BLOCK_LOCK_WR(query_block)
----Query_cache::free_query
------my_hash_delete(&queries,(uchar *) query_block);
------Query_cache::free_query_internal
```


#2.free_query_internal

```cpp
free_query_internal
--query= query_block->query()
--query->writer()->first_query_block= NULL;
--query->writer(0)
--double_linked_list_exclude(query_block, &queries_blocks)
--Query_cache_block_table *table= query_block->table(0);
--for (TABLE_COUNTER_TYPE i= 0; i < query_block->n_tables; i++)
----Query_cache::unlink_table
--Query_cache_block *result_block= query->result();
--Query_cache_block *block= result_block;
--while (block != result_block);
----Query_cache_block *current= block;
----block= block->next;
----free_memory_block(current);
--query->unlock_n_destroy()
--free_memory_block(query_block)
```