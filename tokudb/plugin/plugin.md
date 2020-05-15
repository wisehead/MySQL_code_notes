#1.mysql_declare_plugin(tokudb)

```cpp
#ifdef MARIA_PLUGIN_INTERFACE_VERSION
maria_declare_plugin(tokudb)
#else
mysql_declare_plugin(tokudb)
#endif
    {
        MYSQL_STORAGE_ENGINE_PLUGIN,
        &tokudb_storage_engine,
        tokudb_hton_name,
        "Percona",
        "Percona TokuDB Storage Engine with Fractal Tree(tm) Technology",
        PLUGIN_LICENSE_GPL,
        tokudb_init_func,          /* plugin init */
        tokudb_done_func,          /* plugin deinit */
        TOKUDB_PLUGIN_VERSION,
        toku_global_status_variables_export,  /* status variables */
        tokudb::sysvars::system_variables,   /* system variables */
#ifdef MARIA_PLUGIN_INTERFACE_VERSION
        tokudb::sysvars::version,
        MariaDB_PLUGIN_MATURITY_STABLE /* maturity */
#else
        NULL,                      /* config options */
        0,                         /* flags */
#endif
    },
    tokudb::information_schema::trx,
    tokudb::information_schema::lock_waits,
    tokudb::information_schema::locks,
    tokudb::information_schema::file_map,
    tokudb::information_schema::fractal_tree_info,
    tokudb::information_schema::fractal_tree_block_map,
    tokudb::information_schema::background_job_status
#ifdef MARIA_PLUGIN_INTERFACE_VERSION
maria_declare_plugin_end;
#else
mysql_declare_plugin_end;
#endif
```

#2. mysql_declare_plugin MACRO

```cpp
#define mysql_declare_plugin(NAME) \
__MYSQL_DECLARE_PLUGIN(NAME, \
                 builtin_ ## NAME ## _plugin_interface_version, \
                 builtin_ ## NAME ## _sizeof_struct_st_plugin, \
                 builtin_ ## NAME ## _plugin)

#define mysql_declare_plugin_end ,{0,0,0,0,0,0,0,0,0,0,0,0,0}}
```

#3.rocksdb

```cpp
mysql_declare_plugin(rocksdb_se){
    MYSQL_STORAGE_ENGINE_PLUGIN,       /* Plugin Type */
    &rocksdb_storage_engine,           /* Plugin Descriptor */
    "ROCKSDB",                         /* Plugin Name */
    "Monty Program Ab",                /* Plugin Author */
    "RocksDB storage engine",          /* Plugin Description */
    PLUGIN_LICENSE_GPL,                /* Plugin Licence */
    myrocks::rocksdb_init_func,        /* Plugin Entry Point */
    myrocks::rocksdb_done_func,        /* Plugin Deinitializer */
    0x0001,                            /* version number (0.1) */
    myrocks::rocksdb_status_vars,      /* status variables */
    myrocks::rocksdb_system_variables, /* system variables */
    nullptr,                                        /* string version */
    0,
},
        myrocks::rdb_i_s_cfstats, myrocks::rdb_i_s_dbstats,
        myrocks::rdb_i_s_perf_context, myrocks::rdb_i_s_perf_context_global,
        myrocks::rdb_i_s_cfoptions, myrocks::rdb_i_s_compact_stats,
        myrocks::rdb_i_s_global_info, myrocks::rdb_i_s_ddl,
        myrocks::rdb_i_s_sst_props, myrocks::rdb_i_s_index_file_map,
        myrocks::rdb_i_s_lock_info, myrocks::rdb_i_s_trx_info,
        myrocks::rdb_i_s_deadlock_info
mysql_declare_plugin_end;
```

#4.innodb

```cpp
mysql_declare_plugin(innobase)
{
  MYSQL_STORAGE_ENGINE_PLUGIN,
  &innobase_storage_engine,
  innobase_hton_name,
  plugin_author,
  "Supports transactions, row-level locking, and foreign keys",
  PLUGIN_LICENSE_GPL,
  innobase_init, /* Plugin Init */
  NULL, /* Plugin Deinit */
  INNODB_VERSION_SHORT,
  innodb_status_variables_export,/* status variables             */
  innobase_system_variables, /* system variables */
  NULL, /* reserved */
  0,    /* flags */
},
i_s_innodb_trx,
i_s_innodb_locks,
i_s_innodb_lock_waits,
i_s_innodb_cmp,
i_s_innodb_cmp_reset,
i_s_innodb_cmpmem,
i_s_innodb_cmpmem_reset,
i_s_innodb_cmp_per_index,
i_s_innodb_cmp_per_index_reset,
i_s_innodb_buffer_page,
i_s_innodb_buffer_page_lru,
i_s_innodb_buffer_stats,
i_s_innodb_metrics,
i_s_innodb_ft_default_stopword,
i_s_innodb_ft_deleted,
i_s_innodb_ft_being_deleted,
i_s_innodb_ft_config,
i_s_innodb_ft_index_cache,
i_s_innodb_ft_index_table,
i_s_innodb_sys_tables,
i_s_innodb_sys_tablestats,
i_s_innodb_sys_indexes,
i_s_innodb_sys_columns,
i_s_innodb_sys_fields,
i_s_innodb_sys_foreign,
i_s_innodb_sys_foreign_cols,
i_s_innodb_sys_tablespaces,
i_s_innodb_sys_datafiles

mysql_declare_plugin_end;
```

#5.plugin_init

```cpp
mysqld_main
--init_server_components//重点！！！！！！！！！！！
----mdl_init
----table_def_init
------Table_cache_manager::init
----hostname_cache_init
----/ssd1/chenhui3/dbpath/log/mysql.err
----binlog related.
----ha_init_errors//Allow storage engine to give real error messages
----plugin_init
----//binlog, mysql_native_password, mysql_old_password, sha256_password, MRG_MYISAM, MEMORY, MyISAM, CSV
----//PERFORMANCE_SCHEMA,  InnoDB,  INNODB_TRX, INNODB_LOCK_WAITS, INNODB_CMP, INNODB_CMP_RESET
----//INNODB_CMPMEM, INNODB_CMPMEM_RESET, INNODB_CMP_PER_INDEX, INNODB_CMP_PER_INDEX_RESET
----//INNODB_BUFFER_PAGE, INNODB_BUFFER_PAGE_LRU，INNODB_BUFFER_POOL_STATS， INNODB_METRICS，
----//INNODB_FT_DEFAULT_STOPWORD, INNODB_FT_DELETED, INNODB_FT_BEING_DELETED, INNODB_FT_CONFIG
----//INNODB_FT_INDEX_CACHE, INNODB_FT_INDEX_TABLE, INNODB_SYS_TABLES, INNODB_SYS_TABLESTATS
----//INNODB_SYS_INDEXES, INNODB_SYS_COLUMNS, INNODB_SYS_FIELDS, INNODB_SYS_FOREIGN, 
----//INNODB_SYS_FOREIGN_COLS, INNODB_SYS_TABLESPACES, INNODB_SYS_DATAFILES, FEDERATED
----//BLACKHOLE, partition, 
------register_builtin//insert to array
------plugin_load_list
------plugin_load
--------init_one_table
----------MDL_request::init
--------open_and_lock_tables
----------open_tables
--------init_read_record
------plugin_initialize
--------innobase_init
```

#6. builtin_plugin

```cpp
builtin_plugin
   builtin_csv_plugin, builtin_heap_plugin, builtin_myisam_plugin, builtin_myisammrg_plugin,  builtin_blackhole_plugin, builtin_federated_plugin, builtin_innobase_plugin, builtin_perfschema_plugin, builtin_partition_plugin, builtin_binlog_plugin, builtin_mysql_password_plugin;

struct st_mysql_plugin *mysql_optional_plugins[]=
{
   builtin_blackhole_plugin, builtin_federated_plugin, builtin_innobase_plugin, builtin_perfschema_plugin, builtin_partition_plugin, 0
};

struct st_mysql_plugin *mysql_mandatory_plugins[]=
{
  builtin_binlog_plugin, builtin_mysql_password_plugin,  builtin_csv_plugin, builtin_heap_plugin, builtin_myisam_plugin, builtin_myisammrg_plugin, 0
};
```