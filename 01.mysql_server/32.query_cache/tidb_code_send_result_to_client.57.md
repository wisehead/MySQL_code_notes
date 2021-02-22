#1.send_result_to_client

```cpp
Query_cache::send_result_to_client
--has_no_cache_directive
--try_lock
--cache_key= make_cache_key(thd, thd->query(), &flags, &tot_length);
--my_hash_search(&queries,(uchar*) cache_key,tot_length);
--BLOCK_LOCK_RD(query_block);
--query = query_block->query();
--result_block= query->result();
--first_result_block= result_block;
--for (; block_table != block_table_end; block_table++)
----check_table_access
----if (table->callback())
------Query_cache_table::callback
--------innobase_query_caching_of_table_permitted
```