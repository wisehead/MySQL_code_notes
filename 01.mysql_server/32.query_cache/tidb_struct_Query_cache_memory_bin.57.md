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