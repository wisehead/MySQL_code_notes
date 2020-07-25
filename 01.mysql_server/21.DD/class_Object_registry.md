#1.class Object_registry

```cpp
/**
  Object registry containing several maps.

  The registry is mainly a collection of maps for each type supported. The
  functions dispatch to the appropriate map based on the key and object type
  parameter. There is no support for locking or thread synchronization. The
  object registry is kind of the single threaded version of the shared
  dictionary cache.

  The object registry is intended to be used as a thread local record of
  which objects have been used.

  The individual maps containing DD object pointers are allocated on demand
  to avoid excessive performance overhead during object instantiation.
*/

class Object_registry {
 private:
  std::unique_ptr<Local_multi_map<Abstract_table>> m_abstract_table_map;
  std::unique_ptr<Local_multi_map<Charset>> m_charset_map;
  std::unique_ptr<Local_multi_map<Collation>> m_collation_map;
  std::unique_ptr<Local_multi_map<Column_statistics>> m_column_statistics_map;
  std::unique_ptr<Local_multi_map<Event>> m_event_map;
  std::unique_ptr<Local_multi_map<Resource_group>> m_resource_group_map;
  std::unique_ptr<Local_multi_map<Routine>> m_routine_map;
  std::unique_ptr<Local_multi_map<Schema>> m_schema_map;
  std::unique_ptr<Local_multi_map<Spatial_reference_system>>
      m_spatial_reference_system_map;
  std::unique_ptr<Local_multi_map<Tablespace>> m_tablespace_map;
};   
```