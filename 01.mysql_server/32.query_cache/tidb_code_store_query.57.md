#1.Query_cache::store_query

```cpp
Query_cache::store_query
--Query_cache::is_cacheable
----Query_cache::process_and_count_tables
------*tables_type|= tables_used->table->file->table_cache_type();
--ha_release_temporary_latches
--try_lock
--Query_cache::ask_handler_allowance
----ha_innobase::register_query_cache_table
------innobase_query_caching_of_table_permitted
--------normalize_table_name
--------innobase_register_trx
----------trans_register_ha
----------trx_is_registered_for_2pc
----------trx_register_for_2pc
--------row_search_check_if_query_cache_permitted
----------table = dict_table_open_on_name
----------trx_start_if_not_started
------------trx_start_if_not_started_low
--------------trx_start_low
----------MVCC::view_open
----------dict_table_close
--make_cache_key
--Query_cache_block *competitor = (Query_cache_block *)my_hash_search(&queries, (uchar*) cache_key, tot_length)
--if (competitor == 0)
----Query_cache::write_block_data
------all_headers_len = sizeof(Query_cache_block) + ntab*sizeof(Query_cache_block_table) + header_len
------Query_cache::allocate_block
------memcpy((uchar *) block+ all_headers_len, data, data_len)
--if (query_block != 0)
----header = Query_cache_block::query
------Query_cache_block::data
--------(uchar*)this) + headers_len()
----Query_cache_query::init_n_lock
------mysql_rwlock_init(key_rwlock_query_cache_query_lock, &lock);
------lock_writing
----my_hash_insert(&queries, (uchar*) query_block)
----Query_cache::register_all_tables
------Query_cache::register_tables_from_list
--------Query_cache::insert_table
----double_linked_list_simple_include(query_block, &queries_blocks)
----thd->query_cache_tls.first_query_block= query_block;
----Query_cache_query::writer
----Query_cache::unlock
------mysql_cond_signal(&COND_cache_status_changed);
----Query_cache_query::unlock_writing
------inline_mysql_rwlock_unlock
```