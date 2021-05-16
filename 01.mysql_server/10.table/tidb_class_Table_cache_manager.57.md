#1.class Table_cache_manager

```cpp
/**
  Container class for all table cache instances in the system.
*/

class Table_cache_manager
{
public:

  /** Maximum supported number of table cache instances. */
  static const int MAX_TABLE_CACHES= 64;

  /** Default number of table cache instances */
  static const int DEFAULT_MAX_TABLE_CACHES= 16;
  
private:

  /**
    An array of Table_cache instances.
    Only the first table_cache_instances elements in it are used.
  */
  Table_cache m_table_cache[MAX_TABLE_CACHES];
};  
```