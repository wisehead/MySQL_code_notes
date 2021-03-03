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


#3.Query_cache::move_by_type

```cpp
Query_cache::move_by_type

--case Query_cache_block::FREE
----exclude_from_free_memory_list(block)
----*gap +=block->length;
----block->destroy()
----total_blocks--

--case Query_cache_block::TABLE
----key=query_cache_table_get_key((uchar*) block, &key_length, 0)
------*length = (table_block->used - table_block->headers_len() - ALIGN_SIZE(sizeof(Query_cache_table)));
------return (table_block->data() +ALIGN_SIZE(sizeof(Query_cache_table)));
----my_hash_first(&tables, key, key_length, &record_idx)
----block->destroy()
------type = INCOMPLETE
----new_block->init(len);
----new_block->type=Query_cache_block::TABLE;
----new_block->used=used
----new_block->n_tables=1
----memmove((char*) new_block->data(), data, len-new_block->headers_len())
----relink(block, new_block, next, prev, pnext, pprev)
----Query_cache_table *new_block_table=new_block->table();
----for (;tnext != nlist_root; tnext=tnext->next)
------tnext->parent= new_block_table;
----*border += len
----*before = new_block;
----new_block->table()->table(new_block->table()->db() + tablename_offset)
----my_hash_replace(&tables, &record_idx, (uchar*) new_block);
```