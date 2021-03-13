#1.register_all_tables

```cpp
register_all_tables
--Query_cache_block_table *block_table = block->table(0)
--register_tables_from_list
----for (n= counter;tables_used;tables_used= tables_used->next_global, n++, block_table++)
------block_table->n= n;
------if (tables_used->is_view())
--------get_table_def_key
--------insert_table(key_length, key, block_table, tables_used->view_db.length + 1,HA_CACHE_TBL_NONTRANSACT, 0, 0))
------else
--------insert_table(tables_used->table->s->table_cache_key.length,
                        tables_used->table->s->table_cache_key.str,
                        block_table,
                        tables_used->db_length,
                        tables_used->table->file->table_cache_type(),
                        tables_used->callback_func,
                        tables_used->engine_data)                        
--if (n==0)
----for (Query_cache_block_table *tmp = block->table(0) ;tmp != block_table;tmp++)
------unlink_table
```

#2. insert_table

```cpp
insert_table
--table_block=my_hash_search(&tables, (uchar*) key, key_len)
--if (table_block &&table_block->table()->engine_data() != engine_data)
----list_root= table_block->table(0)
----invalidate_query_block_list(thd, list_root);
------while (list_root->next != list_root)
--------Query_cache_block *query_block= list_root->next->block()
--------BLOCK_LOCK_WR(query_block);
--------free_query(query_block);
--//if (table_block == 0)
--table_block= write_block_data(key_len, (uchar*) key,ALIGN_SIZE(sizeof(Query_cache_table)),Query_cache_block::TABLE, 1);
--
----
```

#3.