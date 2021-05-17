#1.innobase_query_caching_of_table_permitted

```cpp
innobase_query_caching_of_table_permitted
--check_trx_exists
----innobase_trx_init
------trx->check_foreigns = !thd_test_options(thd, OPTION_NO_FOREIGN_KEY_CHECKS);
------trx->check_unique_secondary = !thd_test_options(thd, OPTION_RELAXED_UNIQUE_CHECKS);
--innobase_srv_conc_force_exit_innodb
--if (is_autocommit && trx->n_mysql_tables_in_use == 0)
----return((my_bool)TRUE);
--create_table_info_t::normalize_table_name_low
--innobase_register_trx
--row_search_check_if_query_cache_permitted

```

#2.row_search_check_if_query_cache_permitted

```cpp
row_search_check_if_query_cache_permitted
--dict_table_open_on_name
--trx_start_if_not_started
----trx_start_if_not_started_low
------trx_start_low
```