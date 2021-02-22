#1.class Query_cache

```cpp
class Query_cache
{
public:
  /* Info */
  ulong query_cache_size, query_cache_limit;
  /* statistics */
  ulong free_memory, queries_in_cache, hits, inserts, refused,
    free_memory_blocks, total_blocks, lowmem_prunes;


private:
#ifndef DBUG_OFF
  my_thread_id m_cache_lock_thread_id;
#endif
  mysql_cond_t COND_cache_status_changed;
  enum Cache_lock_status { UNLOCKED, LOCKED_NO_WAIT, LOCKED };
  Cache_lock_status m_cache_lock_status;

  bool m_query_cache_is_disabled;
protected:
  /*
    The following mutex is locked when searching or changing global
    query, tables lists or hashes. When we are operating inside the
    query structure we locked an internal query block mutex.
    LOCK SEQUENCE (to prevent deadlocks):
      1. structure_guard_mutex
      2. query block (for operation inside query (query block/results))

    Thread doing cache flush releases the mutex once it sets
    m_cache_status flag, so other threads may bypass the cache as
    if it is disabled, not waiting for reset to finish.  The exception
    is other threads that were going to do cache flush---they'll wait
    till the end of a flush operation.
  */
  mysql_mutex_t structure_guard_mutex;
  uchar *cache;                 // cache memory
  Query_cache_block *first_block;       // physical location block list
  Query_cache_block *queries_blocks;        // query list (LIFO)
  Query_cache_block *tables_blocks;

  Query_cache_memory_bin *bins;         // free block lists
  Query_cache_memory_bin_step *steps;       // bins spacing info
  HASH queries, tables;
  /* options */
  ulong min_allocation_unit, min_result_data_size;
  uint def_query_hash_size, def_table_hash_size;

  uint mem_bin_num, mem_bin_steps;      // See at init_cache & find_bin

  my_bool initialized;
};    
```