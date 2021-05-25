#1.query_cache_insert

```cpp
/*****************************************************************************
  Functions to store things into the query cache
*****************************************************************************/

/*
  Note on double-check locking (DCL) usage.

  Below, in query_cache_insert(), query_cache_abort() and
  Query_cache::end_of_result() we use what is called double-check
  locking (DCL) for Query_cache_tls::first_query_block.
  I.e. we test it first without a lock, and, if positive, test again
  under the lock.

  This means that if we see 'first_query_block == 0' without a
  lock we will skip the operation.  But this is safe here: when we
  started to cache a query, we called Query_cache::store_query(), and
  'first_query_block' was set to non-zero in this thread (and the
  thread always sees results of its memory operations, mutex or not).
  If later we see 'first_query_block == 0' without locking a
  mutex, that may only mean that some other thread have reset it by
  invalidating the query.  Skipping the operation in this case is the
  right thing to do, as first_query_block won't get non-zero for
  this query again.

  See also comments in Query_cache::store_query() and
  Query_cache::send_result_to_client().

  NOTE, however, that double-check locking is not applicable in
  'invalidate' functions, as we may erroneously skip invalidation,
  because the thread doing invalidation may never see non-zero
  'first_query_block'.
*/


query_cache_insert
--Query_cache::insert
```

#2.Query_cache::insert

```cpp
Query_cache::insert
--if (is_disabled() || query_cache_tls->first_query_block == NULL)//由于异常abort
----return
--query_block->query()->state.atomic_compare_and_swap(&old, Query_cache_query::INSERTING)
--append_result_data
----if (*current_block == 0)
------write_result_data(current_block, data_len, data, query_block, Query_cache_block::RES_BEG));
--------allocate_data_chain
----------while (1)
------------allocate_block
--------------while (block == 0 && !free_old_query())
----------------free_old_query
----------------get_free_block
------------------char *p = (char*)malloc(len);
------------new_block->type = Query_cache_block::RES_INCOMPLETE;
------------Query_cache_result *header = new_block->result();
--------if (success)
----------while (block != *result_block);
------------block->type = type;//RES_BEG or RES_CONT
------------memcpy((uchar*) block+headers_len, rest, length);
------------block = block->next;
------------type = Query_cache_block::RES_CONT;
--------else
----------while (block != *result_block);
------------free_memory_block(current);
------------block = block->next;

```

#3. free_old_query

```cpp
free_old_query
--RW_RLOCK(&dlink_queries_blocks_rwlock);//chenhui
--while ((block=block->next) != queries_blocks )
----if (header->result() != 0 && header->result()->type == Query_cache_block::RESULT && header->state.atomic_get() == 0  && block->query()->try_lock_writing())
------query_block->query()->state.atomic_set(Query_cache_query::FREEING);//chenhui
------	BLOCK_UNLOCK_WR(query_block);
--RW_UNLOCK(&dlink_queries_blocks_rwlock);//chenhui
--free_query
```

#4.free_query
```cpp
free_query
--lf_hash_delete(&queries_hash, pins, cache_key, len);
--free_query_internal
----if (query->writer() != 0)
------query->writer()->first_query_block= NULL;
------query->writer(0);
----double_linked_list_exclude(query_block, &queries_blocks);
----for (TABLE_COUNTER_TYPE i= 0; i < query_block->n_tables; i++)
------unlink_table
--------node->prev->next= node->next;
--------node->next->prev= node->prev;
--------if (neighbour->next == neighbour)
----------double_linked_list_exclude(table_block, &tables_blocks);
----------my_hash_delete(&tables,(uchar *) table_block);
----------node->parent->unlock_n_destroy();//chenhui
----------free_memory_block(table_block);
----while (block != result_block);
------free_memory_block(current);
----query->unlock_n_destroy();
----free_memory_block(query_block);
```

