#1.TiDB_rpl_sys::log_scan_handler

```cpp

TiDB_rpl_sys::log_scan_handler
--tidb_server_create_thd//thread pool
--TiDB_DDL_Opr_Ctl::tidb_apply_meta_change_start//Apply meta data change start.
--UT_LIST_GET_FIRST(ddl_start_list)
--tidb_apply_meta_change
----build_table_filename
----normalize_table_name
----if (type == META_CHANGE_END) 
------tidb_apply_meta_del(norm_name);
--------ddl_table_set.erase(std::string(table_name));
----tidb_server_apply_meta_change
------case META_CHANGE_START:
--------tidb_acquire_mdl
------case META_CHANGE_END:
--------tidb_release_mdl
----innobase_evict_dict_cache
------dict_table_evict_by_name
--------dict_table_check_if_in_cache_low
----------HASH_SEARCH(name_hash, dict_sys->table_hash, table_fold,
--------btr_search_clear_on_table
--------dict_stats_stop_bg//Request the background collection of statistics to stop for a table
--------dict_table_remove_from_cache
----------dict_table_remove_from_cache_low
----if (type == META_CHANGE_START)
------tidb_apply_meta_add(norm_name);
--------ddl_table_set.insert(std::string(table_name));
--UT_LIST_REMOVE(ddl_start_list, ddl_opr);
```