#1.query_cache_tls->first_query_block

```cpp

```

#2. store_query
```cpp
//在handle_select()之前调用，用于注册result set writer（thd->net.query_cache_query）。

store_query
--query_block= write_block_data
--my_hash_insert(&queries, (uchar*) query_block)
--register_all_tables(query_block, tables_used, local_tables)
--double_linked_list_simple_include(query_block, &queries_blocks);
--thd->query_cache_tls.first_query_block= query_block;
--header->writer(&thd->query_cache_tls);
--unlock();
--BLOCK_UNLOCK_WR(query_block);
```

#3. query_cache_insert

```cpp
net_write_packet函数会调用它将结果插入query cache，需要query已经注册result set writer（thd->net.query_cache_query）。
```

#4.insert

```cpp
insert
--query_block = query_cache_tls->first_query_block
--BLOCK_LOCK_WR(query_block);
--Query_cache_query *header= query_block->query();
--Query_cache_block *result= header->result()
--append_result_data(&result, length, (uchar*) packet,query_block))
--header->result(result);
--header->last_pkt_nr= pkt_nr;
--BLOCK_UNLOCK_WR(query_block);
```

#5.abort

```cpp
BLOCK_LOCK_WR(query_block);
free_query(query_block);
query_cache_tls->first_query_block= NULL;
```

#6.end_of_result

```cpp
BLOCK_LOCK_WR(query_block);
Query_cache_query *header= query_block->query();
header->found_rows(current_found_rows);
header->result()->type= Query_cache_block::RESULT;
header->writer(0);
query_cache_tls->first_query_block= NULL;
BLOCK_UNLOCK_WR(query_block);
```

#7.resize

```cpp
while (block != queries_blocks)
--BLOCK_LOCK_WR(block);
--Query_cache_query *query= block->query();
--if (query->writer())
----query->writer()->first_query_block= NULL;
----query->writer(0);
----refused++;
--query->unlock_n_destroy();
--block= block->next;
```

#8.free_query_internal

```cpp
query->writer()->first_query_block= NULL;
query->writer(0);
double_linked_list_exclude(query_block, &queries_blocks);
for (TABLE_COUNTER_TYPE i= 0; i < query_block->n_tables; i++)
--unlink_table(table++);
while (block != result_block);
--Query_cache_block *current= block;
--block= block->next;
--free_memory_block(current);
--query->unlock_n_destroy();
--free_memory_block(query_block)
```