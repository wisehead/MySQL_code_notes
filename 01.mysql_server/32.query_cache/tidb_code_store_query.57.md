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
```