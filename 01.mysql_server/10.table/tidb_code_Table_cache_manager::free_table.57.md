#1.Table_cache_manager::free_table

```cpp
Table_cache_manager::free_table
--memcpy(&cache_el, share->cache_element,table_cache_instances * sizeof(Table_cache_element *));
--for (uint i= 0; i < table_cache_instances; i++)
----if (cache_el[i])
------while ((table= it++))
--------m_table_cache[i].remove_table(table);
--------intern_close_table(table)
```