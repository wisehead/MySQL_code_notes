#1.insert_into_free_memory_list

```cpp
insert_into_free_memory_list
--idx = find_bin(free_block->length)//二分查找
--insert_into_free_memory_sorted_list(free_block, &bins[idx].free_blocks)
--Query_cache_memory_bin **bin_ptr = ((Query_cache_memory_bin**)free_block->data());
--*bin_ptr = bins+idx;
--(*bin_ptr)->number++
```

#2.insert_into_free_memory_sorted_list

```cpp
insert_into_free_memory_sorted_list
--new_block->used = 0;
--new_block->n_tables = 0;
--new_block->type = Query_cache_block::FREE;
--//按照block size 升序排序，插入到合适的位置。
```