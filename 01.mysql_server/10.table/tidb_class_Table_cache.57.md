#1.class Table_cache

```cpp
/**
  Cache for open TABLE objects.

  The idea behind this cache is that most statements don't need to
  go to a central table definition cache to get a TABLE object and
  therefore don't need to lock LOCK_open mutex.
  Instead they only need to go to one Table_cache instance (the
  specific instance is determined by thread id) and only lock the
  mutex protecting this cache.
  DDL statements that need to remove all TABLE objects from all caches
  need to lock mutexes for all Table_cache instances, but they are rare.

  This significantly increases scalability in some scenarios.
*/
class Table_cache
{
private:
  /**
    The table cache lock protects the following data:

    1) m_unused_tables list.
    2) m_cache hash.
    3) used_tables, free_tables lists in Table_cache_element objects in
       this cache.
    4) m_table_count - total number of TABLE objects in this cache.
    5) the element in TABLE_SHARE::cache_element[] array that corresponds
       to this cache,
    6) in_use member in TABLE object.
    7) Also ownership of mutexes for all caches are required to update
       the refresh_version and table_def_shutdown_in_progress variables
       and TABLE_SHARE::version member.

    The intention is that any query that finds a cached table object in
    its designated table cache should only need to lock this mutex
    instance and there should be no need to lock LOCK_open. LOCK_open is
    still required however to create and release TABLE objects. However
    most usage of the MySQL Server should be able to set the cache size
    big enough so that the majority of the queries only need to lock this
    mutex instance and not LOCK_open.
  */
  mysql_mutex_t m_lock;

  /**
    The hash of Table_cache_element objects, each table/table share that
    has any TABLE object in the Table_cache has a Table_cache_element from
    which the list of free TABLE objects in this table cache AND the list
    of used TABLE objects in this table cache is stored.
    We use Table_cache_element::share::table_cache_key as key for this hash.
  */
  HASH m_cache;

  /**
    List that contains all TABLE instances for tables in this particular
    table cache that are in not use by any thread. Recently used TABLE
    instances are appended to the end of the list. Thus the beginning of
    the list contains which have been least recently used.
  */
  TABLE *m_unused_tables;

  /**
    Total number of TABLE instances for tables in this particular table
    cache (both in use by threads and not in use).
    This value summed over all table caches is accessible to users as
    Open_tables status variable.
  */
  uint m_table_count;
};   
```