#1.open_and_lock_tables
```cpp
/**
  Open all tables in list, locks them and optionally process derived tables.

  @param thd              Thread context.
  @param tables               List of tables for open and locking.
  @param derived              If to handle derived tables.
  @param flags                Bitmap of options to be used to open and lock
                              tables (see open_tables() and mysql_lock_tables()
                              for details).
  @param prelocking_strategy  Strategy which specifies how prelocking algorithm
                              should work for this statement.

  @note
    The thr_lock locks will automatically be freed by
    close_thread_tables().

  @retval FALSE  OK.
  @retval TRUE   Error
*/

open_and_lock_tables
--open_tables
```

#2. open_normal_and_derived_tables

```cpp
open_normal_and_derived_tables
--open_tables
```

#3.open_temporary_tables

```cpp
caller:
--mysql_execute_command

open_temporary_tables
--open_temporary_table
----find_temporary_table
```


#4. open_tables

```cpp
open_tables
--lock_table_names
----mdl_requests.push_front(&table->mdl_request);
----MDL_context::acquire_locks
--open_and_process_table
----open_table
------get_table_def_key
------get_table_share_with_discover
--------get_table_share
----------alloc_table_share
----------open_table_def
------open_table_from_share
```

#5. get_table_share

```cpp
caller:
--get_table_share_with_discover


get_table_share
--alloc_table_share
--open_table_def
----inline_mysql_file_open
------my_open
----inline_mysql_file_read
----open_binary_frm
------ha_lock_engine
--------plugin_lock
----------intern_plugin_lock
```

#6.open_table_from_share

```cpp
caller:
--open_table

open_table_from_share
--handler::ha_open
----ha_innobase::open
------normalize_table_name_low
------get_share
------dict_table_open_on_name
--------dict_load_table//see 01.dic
--------dict_move_to_mru
----------UT_LIST_ADD_FIRST(table_LRU, dict_sys->table_LRU, table);
------innobase_copy_frm_flags_from_table_share
------dict_stats_init
--------dict_stats_update
----------dict_stats_table_clone_create
----------dict_stats_fetch_from_ps
------------dict_stats_empty_table
------------trx_allocate_for_background
--------------trx_create_low
------------trx_start_internal_low
--------------trx_start_low
------------pars_info_create
------------pars_info_add_str_literal
--------------pars_info_add_literal
------------pars_info_bind_function
--------------callback is dict_stats_fetch_table_stats_step
------------que_eval_sql//innodb内部调用sql 的方法
--------------pars_sql
--------------que_fork_start_command
------------trx_commit_for_mysql
----------dict_table_stats_lock
----------dict_stats_empty_table
----------dict_stats_copy
----------dict_table_stats_unlock
----------dict_stats_table_clone_free
------row_create_prebuilt
------innobase_build_index_translation
------thr_lock_data_init
```
