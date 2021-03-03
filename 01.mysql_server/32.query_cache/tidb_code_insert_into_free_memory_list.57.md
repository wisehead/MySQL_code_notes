#1.insert_into_free_memory_list

```cpp
insert_into_free_memory_list
--idx = find_bin(free_block->length)//二分查找
--insert_into_free_memory_sorted_list(free_block, &bins[idx].free_blocks)
```

#2.insert_into_free_memory_sorted_list

```cpp
insert_into_free_memory_sorted_list
--
```