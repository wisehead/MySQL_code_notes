#1.struct Query_cache_memory_bin_step

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