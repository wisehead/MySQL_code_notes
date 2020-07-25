#1.class Dictionary_client

```cpp
class Dictionary_client {
 public:
  /**
    Class to help releasing and deleting objects.

    This class keeps a register of shared objects that are automatically
    released when the instance goes out of scope. When a new instance
    is created, the encompassing dictionary client's current auto releaser
    is replaced by this one, keeping a link to the old one. When the
    auto releaser is deleted, it links the old releaser back in as the
    client's current releaser.

    Shared objects that are added to the auto releaser will be released when
    the releaser is deleted. Only the dictionary client is allowed to add
    objects to the auto releaser.

    The usage pattern is that objects that are retrieved from the shared
    dictionary cache are added to the current auto releaser. Objects that
    are retrieved from the client's local object register are not added to
    the auto releaser. Thus, when the releaser is deleted, it releases all
    objects that have been retrieved from the shared cache during the
    lifetime of the releaser.

    Similarly the auto releaser maintains a list of objects created
    by acquire_uncached(). These objects are owned by the Auto_releaser
    and are deleted when the auto releaser goes out of scope.
  */
 private:
  std::vector<Entity_object *> m_uncached_objects;  // Objects to be deleted.
  Object_registry m_registry_committed;    // Registry of committed objects.
  Object_registry m_registry_uncommitted;  // Registry of uncommitted objects.
  Object_registry m_registry_dropped;      // Registry of dropped objects.
  THD *m_thd;                        // Thread context, needed for cache misses.
  Auto_releaser m_default_releaser;  // Default auto releaser.
  Auto_releaser *m_current_releaser;  // Current auto releaser.

  /**
    Se-private ids known not to exist in either TABLES or PARTITIONS
    or both.
  */
  SPI_lru_cache_owner_ptr m_no_table_spids;
};    
```