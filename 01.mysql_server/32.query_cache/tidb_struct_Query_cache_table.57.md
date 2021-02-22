#1.struct Query_cache_table

```cpp
struct Query_cache_table
{
  Query_cache_table() {}                      /* Remove gcc warning */
  char *tbl;
  uint32 key_len;
  uint8 table_type;
  /* unique for every engine reference */
  qc_engine_callback callback_func;
  /* data need by some engines */
  ulonglong engine_data_buff;

  /**
    The number of queries depending of this table.
  */
  int32 m_cached_query_count;
}
```