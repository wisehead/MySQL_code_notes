#1.Table_cache_manager

```cpp
/**
  Container class for all table cache instances in the system.
*/

class Table_cache_manager
{
public:

  /** Maximum supported number of table cache instances. */
  static const int MAX_TABLE_CACHES= 64;

  bool init();
  void destroy();

  /** Get instance of table cache to be used by particular connection. */
  Table_cache* get_cache(THD *thd)
  {
    return &m_table_cache[thd->thread_id % table_cache_instances];
  }

  /** Get index for the table cache in container. */
  uint cache_index(Table_cache *cache) const
  {
    return (cache - &m_table_cache[0]);
  }

  uint cached_tables();

  void lock_all_and_tdc();
  void unlock_all_and_tdc();
  void assert_owner_all();
  void assert_owner_all_and_tdc();

  void free_table(THD *thd,
                  enum_tdc_remove_table_type remove_type,
                  TABLE_SHARE *share);

  void free_all_unused_tables();

#ifndef DBUG_OFF
  void print_tables();
#endif

  friend class Table_cache_iterator;
private:

  /**
    An array of Table_cache instances.
    Only the first table_cache_instances elements in it are used.
  */
  Table_cache m_table_cache[MAX_TABLE_CACHES];
};  
```