#1.invalidate_single

```cpp
caller:
- invalidate
- mysql_delete
- invalidate_delete_tables
- mysql_insert
- mysql_rm_table_no_locks
- invalidate_update_tables


invalidate_single
--if (using_transactions &&(table_used->table->file->table_cache_type() ==HA_CACHE_TBL_TRANSACT))
----thd->add_changed_table(table_used->table)
--else
----Query_cache::invalidate_table(THD *thd, TABLE *table)
------invalidate_table(thd, (uchar*) table->s->table_cache_key.str,table->s->table_cache_key.length);
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