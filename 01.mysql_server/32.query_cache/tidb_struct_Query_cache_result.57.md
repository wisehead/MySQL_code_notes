#1.struct Query_cache_result

```cpp
struct Query_cache_result
{
  Query_cache_result() {}                     /* Remove gcc warning */
  Query_cache_block *query;

  inline uchar* data()
  {
    return (uchar*)(((uchar*) this)+
          ALIGN_SIZE(sizeof(Query_cache_result)));
  }
  /* data_continue (if not whole packet contained by this block) */
  inline Query_cache_block *parent()          { return query; }
  inline void parent (Query_cache_block *p)   { query=p; }
};
```