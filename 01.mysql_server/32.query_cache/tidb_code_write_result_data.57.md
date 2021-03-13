#1.write_result_data

```cpp
caller:
- append_result_data

write_result_data
--allocate_data_chain
----do
------new_block= allocate_block(max(min_size, align_len),min_result_data_size == 0,all_headers_len + min_result_data_size)))
------new_block->used = min(len, new_block->length);
------if (prev_block)
--------double_linked_list_join(prev_block, new_block);
------else
-------*result_block= new_block;
------if (new_block->length >= len)
--------break;
----while (1);
--if (success)
----unlock();
----while (block != *result_block);
------memcpy((uchar*) block+headers_len, rest, length);
------type = Query_cache_block::RES_CONT;
--else
----while (block != *result_block);
------free_memory_block(current);
```