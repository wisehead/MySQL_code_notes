#1.ha_innobase::create

```cpp
ha_innobase::create
--create_options_are_invalid
--innobase_table_flags
--innobase_index_name_is_reserved
--check_trx_exists
----thd_to_trx
------thd_ha_data
----innobase_trx_init
--innobase_trx_allocate
----trx_allocate_for_mysql
------trx_allocate_for_background
--------trx_create_low
----------PoolManager<Pool<trx_t, TrxFactory, TrxPoolLock>, TrxPoolManagerLock>::get
------------Pool<trx_t, TrxFactory, TrxPoolLock>::get
------UT_LIST_ADD_FIRST(mysql_trx_list, trx_sys->mysql_trx_list, trx);
----innobase_trx_init
--create_table_def
--create_index
--innobase_get_stmt
--row_table_add_foreign_constraints
----dict_create_foreign_constraints
------dict_create_foreign_constraints_low
--innobase_commit_low
--log_buffer_flush_to_disk
--innobase_copy_frm_flags_from_create_info
--dict_stats_update
----dict_stats_save
------dict_stats_exec_sql
--------que_eval_sql
--dict_table_close
--trx_free_for_mysql
```

#2. create_table_def

```cpp
create_table_def
--create_table_check_doc_id_col
----dict_mem_table_create
--dict_mem_table_add_col
----dict_add_col_name
--row_create_table_for_mysql
```

#3. create_index

```cpp
create_index
--dict_mem_index_create
----dict_mem_fill_index_struct
--dict_mem_index_add_field
--row_create_index_for_mysql
```