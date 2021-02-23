#1.Query_cache::write_block_data

```cpp
Query_cache::write_block_data
--all_headers_len = sizeof(Query_cache_block) + ntab*sizeof(Query_cache_block_table) + header_len
--Query_cache::allocate_block
----Query_cache::get_free_block
------Query_cache::find_bin
------Query_cache::exclude_from_free_memory_list
--------Query_cache_block::data
----------Query_cache_block::headers_len
--------Query_cache::double_linked_list_exclude
--------bin->number--
--------free_memory-=free_block->length;
--------free_memory_blocks--
----if (block->length >= ALIGN_SIZE(len) + min_allocation_unit)
------Query_cache::split_block
--------new_block = (Query_cache_block*)(((uchar*) block)+len)
--------Query_cache_block::init
--------new_block->pnext = block->pnext
--------block->pnext = new_block
--------new_block->pnext->pprev = new_block;
--------if (block->type == Query_cache_block::FREE)
----------Query_cache::insert_into_free_memory_list
------------Query_cache::find_bin
------------Query_cache::insert_into_free_memory_sorted_list
--block->type = type;
--block->n_tables = ntab
--block->used = static_cast<ulong>(len);
--memcpy((uchar *) block+ all_headers_len, data, data_len)
```