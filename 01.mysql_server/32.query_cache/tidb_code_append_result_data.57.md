#1.append_result_data

```cpp
caller:
- insert// with lock BLOCK_LOCK_WR(query_block)


append_result_data
--if (query_block->query()->add(data_len) > query_cache_limit)
----DBUG_RETURN(0)
--if (*current_block == 0)
----write_result_data
--if (last_block_free_space < data_len &&append_next_free_block(last_block,max(tail, append_min)))
----last_block_free_space = last_block->length - last_block->used;
--if (last_block_free_space < data_len)
----write_result_data(&new_block, data_len-last_block_free_space, (uchar*)(data+last_block_free_space),query_block,Query_cache_block::RES_CONT);
----double_linked_list_join(last_block, new_block);
--if (success && last_block_free_space > 0)
----memcpy((uchar*) last_block + last_block->used, data, to_copy);
```

#2.append_next_free_block

```cpp
append_next_free_block
--Query_cache_block *next_block = block->pnext;//physical block
--if (next_block != first_block && next_block->is_free())
----exclude_from_free_memory_list(next_block);
----next_block->destroy();
----block->length += next_block->length;
----block->pnext = next_block->pnext;
----next_block->pnext->pprev = block;
----if (block->length > ALIGN_SIZE(old_len + add_size) + min_allocation_unit)
------split_block(block,ALIGN_SIZE(old_len + add_size));
```
