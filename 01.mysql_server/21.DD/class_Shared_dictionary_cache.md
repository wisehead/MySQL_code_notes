#1.class Shared_dictionary_cache

```cpp
/**
  Shared dictionary cache containing several maps.

  The dictionary cache is mainly a collection of shared maps for the
  object types supported. The functions dispatch to the appropriate
  map based on the key and object type parameter. Cache misses are handled
  by retrieving the object from the storage adapter singleton.

  The shared dictionary cache itself does not handle concurrency at this
  outer layer. Concurrency is handled by the various instances of the
  shared multi map.
*/

class Shared_dictionary_cache {
 private:
  // Collation and character set cache sizes are chosen so that they can hold
  // all collations and character sets built into the server. The spatial
  // reference system cache size is chosen to hold a reasonable number of SRSs
  // for normal server use.
  static const size_t collation_capacity = 256;
  static const size_t column_statistics_capacity = 32;
  static const size_t charset_capacity = 64;
  static const size_t event_capacity = 256;
  static const size_t spatial_reference_system_capacity = 256;
  /**
    Maximum number of DD resource group objects to be kept in
    cache. We use value of 32 which is a fairly reasonable upper limit
    of resource group configurations that may be in use.
  */
  static const size_t resource_group_capacity = 32;

  Shared_multi_map<Abstract_table> m_abstract_table_map;
  Shared_multi_map<Charset> m_charset_map;
  Shared_multi_map<Collation> m_collation_map;
  Shared_multi_map<Column_statistics> m_column_stat_map;
  Shared_multi_map<Event> m_event_map;
  Shared_multi_map<Resource_group> m_resource_group_map;
  Shared_multi_map<Routine> m_routine_map;
  Shared_multi_map<Schema> m_schema_map;
  Shared_multi_map<Spatial_reference_system> m_spatial_reference_system_map;
  Shared_multi_map<Tablespace> m_tablespace_map;
};  
```
