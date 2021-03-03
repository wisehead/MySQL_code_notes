#1.free_memory_block

```
free_memory_block
--block->used=0
--block->type= Query_cache_block::FREE
--if (block->pnext != first_block && block->pnext->is_free())
----block = join_free_blocks(block, block->pnext);
--if (block != first_block && block->pprev->is_free())
----block = join_free_blocks(block->pprev, block->pprev);
--insert_into_free_memory_list(block);

```


#2.Query_cache::join_free_blocks

```cpp
Query_cache::join_free_blocks
--exclude_from_free_memory_list(block_in_list);
--second_block = first_block_arg->pnext;
--second_block->used=0;
--second_block->destroy()
--total_blocks--;
```