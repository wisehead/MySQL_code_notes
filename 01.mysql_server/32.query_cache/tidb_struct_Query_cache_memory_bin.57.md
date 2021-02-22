#1.struct Query_cache_memory_bin

```cpp
struct Query_cache_memory_bin
{
  Query_cache_memory_bin() {}                 /* Remove gcc warning */
#ifndef DBUG_OFF
  ulong size;
#endif
  uint number;
  Query_cache_block *free_blocks;

  inline void init(ulong size_arg)
  {
#ifndef DBUG_OFF
    size = size_arg;
#endif
    number = 0;
    free_blocks = 0;
  }
};

```

#2.struct Query_cache_memory_bin_step

```cpp
struct Query_cache_memory_bin_step
{
  Query_cache_memory_bin_step() {}            /* Remove gcc warning */
  ulong size;
  ulong increment;
  uint idx;
  inline void init(ulong size_arg, uint idx_arg, ulong increment_arg)
  {
    size = size_arg;
    idx = idx_arg;
    increment = increment_arg;
  }
};
```