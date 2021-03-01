#1.Query_cache::init_cache

```cpp
Query_cache::init_cache
--max_mem_bin_size = query_cache_size >> QUERY_CACHE_MEM_BIN_FIRST_STEP_PWR2;
--mem_bin_count = (uint)  ((1 + QUERY_CACHE_MEM_BIN_PARTS_INC) *QUERY_CACHE_MEM_BIN_PARTS_MUL);
--mem_bin_size = max_mem_bin_size >> QUERY_CACHE_MEM_BIN_STEP_PWR2;
--mem_bin_num = 1;
--mem_bin_steps = 1;
--while (mem_bin_size > min_allocation_unit)
  {
    mem_bin_num += mem_bin_count;
    prev_size = mem_bin_size;
    mem_bin_size >>= QUERY_CACHE_MEM_BIN_STEP_PWR2;
    mem_bin_steps++;
    mem_bin_count += QUERY_CACHE_MEM_BIN_PARTS_INC;
    mem_bin_count = (uint) (mem_bin_count * QUERY_CACHE_MEM_BIN_PARTS_MUL);

    // Prevent too small bins spacing
    if (mem_bin_count > (mem_bin_size >> QUERY_CACHE_MEM_BIN_SPC_LIM_PWR2))
      mem_bin_count= (mem_bin_size >> QUERY_CACHE_MEM_BIN_SPC_LIM_PWR2);
  }
--inc = (prev_size - mem_bin_size) / mem_bin_count;
--mem_bin_num += (mem_bin_count - (min_allocation_unit - mem_bin_size)/inc);
--steps = (Query_cache_memory_bin_step *) cache;
--bins = ((Query_cache_memory_bin *)(cache + mem_bin_steps *ALIGN_SIZE(sizeof(Query_cache_memory_bin_step))));
--first_block = (Query_cache_block *) (cache + additional_data_size);
```