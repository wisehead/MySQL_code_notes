#1.invalidate_single

```cpp
invalidate_single
--
```


#2.invalidate_changed_tables_in_cache

```cpp
caller:
- ha_commit_low

invalidate_changed_tables_in_cache
--if (m_changed_tables)
----invalidate(CHANGED_TABLE_LIST *tables_used)

```

#3.invalidate(CHANGED_TABLE_LIST *tables_used)

```cpp
invalidate
--for (; tables_used; tables_used= tables_used->next)
----Query_cache::invalidate_table(THD *thd, uchar * key, size_t key_length)
```

#4.Query_cache::invalidate_table(THD *thd, uchar * key, size_t key_length)

```cpp
Query_cache::invalidate_table(THD *thd, uchar * key, size_t key_length)
--lock()
--invalidate_table_internal
----table_block=(Query_cache_block*)my_hash_search(&tables, key, key_length);
----list_root= table_block->table(0)
----invalidate_query_block_list
------while (list_root->next != list_root)
--------Query_cache_block *query_block= list_root->next->block();
--------BLOCK_LOCK_WR(query_block);
--------free_query
----------my_hash_delete(&queries,(uchar *) query_block);
----------free_query_internal
--unlock
```