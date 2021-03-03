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

--case Query_cache_block::QUERY:
----BLOCK_LOCK_WR(block);
----char *data = (char*) block->data();
----Query_cache_block *first_result_block = ((Query_cache_query *)block->data())->result();
----key=query_cache_query_get_key((uchar*) block, &key_length, 0);
----my_hash_first(&queries, key, key_length, &record_idx);
----memmove((char*) new_block->table(0), (char*) block->table(0),ALIGN_SIZE(n_tables*sizeof(Query_cache_block_table)));
----block->query()->unlock_n_destroy();
----block->destroy()
----new_block->init(len);
----new_block->type=Query_cache_block::QUERY;
----new_block->used=used;
----new_block->n_tables=n_tables;
----memmove((char*) new_block->data(), data, len - new_block->headers_len());
----relink(block, new_block, next, prev, pnext, pprev);
----if (queries_blocks == block)
------queries_blocks = new_block;
----for (TABLE_COUNTER_TYPE j=0; j < n_tables; j++)//为了解决指向自己的情况。只有一个。。。。。特殊情况
    {
      Query_cache_block_table *block_table = new_block->table(j);

      // use aligment from begining of table if 'next' is in same block
      if ((beg_of_table_table <= block_table->next) &&
          (block_table->next < end_of_table_table))
        ((Query_cache_block_table *)(beg_of_new_table_table +
                                     (((uchar*)block_table->next) -
                                      ((uchar*)beg_of_table_table))))->prev=
         block_table;
      else
        block_table->next->prev= block_table;

      // use aligment from begining of table if 'prev' is in same block
      if ((beg_of_table_table <= block_table->prev) &&
          (block_table->prev < end_of_table_table))
        ((Query_cache_block_table *)(beg_of_new_table_table +
                                     (((uchar*)block_table->prev) -
                                      ((uchar*)beg_of_table_table))))->next=
          block_table;
      else
        block_table->prev->next = block_table;
    }
----*border += len;
----*before = new_block;
----new_block->query()->result(first_result_block);
----Query_cache_block *result_block = first_result_block;
----while ( result_block != first_result_block )
------result_block->result()->parent(new_block);
------result_block = result_block->next;
----Query_cache_query *new_query= ((Query_cache_query *) new_block->data());
----mysql_rwlock_init(key_rwlock_query_cache_query_lock, &new_query->lock);
----Query_cache_tls *query_cache_tls= new_block->query()->writer();
----query_cache_tls->first_query_block= new_block;
----my_hash_replace(&queries, &record_idx, (uchar*) new_block);

--case Query_cache_block::RES_INCOMPLETE:
  case Query_cache_block::RES_BEG:
  case Query_cache_block::RES_CONT:
  case Query_cache_block::RESULT:
----Query_cache_block *query_block= block->result()->parent();
----BLOCK_LOCK_WR(query_block);
----block->destroy()
----new_block->init(len);
----memmove((char*) new_block->data(), data, len - new_block->headers_len());
----relink(block, new_block, next, prev, pnext, pprev);
----new_block->result()->parent(query_block);
----Query_cache_query *query = query_block->query();
----if (query->result() == block)
------query->result(new_block);
----*border += len;
----*before = new_block;
----ulong free_space= new_block->length - new_block->used;
    free_space-= free_space % ALIGN_SIZE(1);
    if (query->result()->type == Query_cache_block::RESULT &&
        new_block->length > new_block->used &&
        *gap + free_space > min_allocation_unit &&
        new_block->length - free_space > min_allocation_unit)
    {
      *border-= free_space;
      *gap+= free_space;
      DBUG_PRINT("qcache",
                 ("rest of result free space added to gap (%lu)", *gap));
      new_block->length -= free_space;
    }
----BLOCK_UNLOCK_WR(query_block);
```
