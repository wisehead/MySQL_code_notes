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

#7.stack of init plugin

```cpp
(gdb) bt
#0  tokudb_init_func (p=0x1629dc0) at /home/chenhui/mysql-5623-trunk/storage/tokudb/hatoku_hton.cc:271
#1  0x00000000005b3971 in ha_initialize_handlerton (plugin=0x14df668) at /home/chenhui/mysql-5623-trunk/sql/handler.cc:665
#2  0x00000000006fc200 in plugin_initialize (plugin=plugin@entry=0x14df668) at /home/chenhui/mysql-5623-trunk/sql/sql_plugin.cc:1137
#3  0x00000000007019a8 in plugin_init (argc=argc@entry=0x138f390 <remaining_argc>, argv=<optimized out>, flags=flags@entry=0) at /home/chenhui/mysql-5623-trunk/sql/sql_plugin.cc:1431
#4  0x00000000005aa752 in init_server_components () at /home/chenhui/mysql-5623-trunk/sql/mysqld.cc:4898
#5  mysqld_main (argc=98, argv=0x13fe4d8) at /home/chenhui/mysql-5623-trunk/sql/mysqld.cc:5495
#6  0x00007ffff6bdbbd5 in __libc_start_main () from /opt/compiler/gcc-4.8.2/lib/libc.so.6
#7  0x000000000059ee95 in _start ()
(gdb) p p
$1 = (void *) 0x1629dc0
(gdb) p ( (handlerton *) p)
$2 = (handlerton *) 0x1629dc0
(gdb) p *( (handlerton *) p)
$3 = {state = SHOW_OPTION_YES, db_type = DB_TYPE_UNKNOWN, slot = 4294967295, savepoint_offset = 0, close_connection = 0x0, savepoint_set = 0x0, savepoint_rollback = 0x0, savepoint_rollback_can_release_mdl = 0x0, savepoint_release = 0x0, commit = 0x0,
  rollback = 0x0, prepare = 0x0, recover = 0x0, commit_by_xid = 0x0, rollback_by_xid = 0x0, create_cursor_read_view = 0x0, set_cursor_read_view = 0x0, close_cursor_read_view = 0x0, create = 0x0, drop_database = 0x0, panic = 0x0, start_consistent_snapshot = 0x0,
  flush_logs = 0x0, show_status = 0x0, partition_flags = 0x0, alter_table_flags = 0x0, alter_tablespace = 0x0, fill_is_table = 0x0, flags = 0, binlog_func = 0x0, binlog_log_query = 0x0, release_temporary_latches = 0x0, get_log_status = 0x0,
  create_iterator = 0x0, discover = 0x0, find_files = 0x0, table_exists_in_engine = 0x0, make_pushed_join = 0x0, system_database = 0x0, is_supported_system_table = 0x0, license = 0, data = 0x0}
(gdb) f 2
#2  0x00000000006fc200 in plugin_initialize (plugin=plugin@entry=0x14df668) at /home/chenhui/mysql-5623-trunk/sql/sql_plugin.cc:1137
1137        if ((*plugin_type_initialize[plugin->plugin->type])(plugin))
(gdb) info args
plugin = 0x14df668
(gdb) p plugin
$4 = (st_plugin_int *) 0x14df668
(gdb) p *plugin
$5 = {name = {str = 0x7fffc1d4a563 "TokuDB", length = 6}, plugin = 0x7fffc1fbc6c0 <_mysql_plugin_declarations_>, plugin_dl = 0x14d6a68, state = 4, ref_count = 0, data = 0x1629dc0, mem_root = {free = 0x14e0df0, used = 0x0, pre_alloc = 0x14e0df0, min_malloc = 32,
    block_size = 4064, block_num = 4, first_block_usage = 0, error_handler = 0x0}, system_vars = 0x14da9f8, load_option = PLUGIN_ON}

```

#8.plugin_init debug

```cpp
plugin_init
--register_builtin
----insert_dynamic(&plugin_array, &tmp)
----my_hash_insert(&plugin_hash[plugin->type],(uchar*) *ptr)
```

#9.plugin list
##9.1 mysql_mandatory_plugins

```cpp
mysql_mandatory_plugins
$18 = (st_mysql_plugin *) 0x12aa6e0 <builtin_binlog_plugin>
$19 = (st_mysql_plugin *) 0x1290540 <builtin_mysql_password_plugin>
$20 = (st_mysql_plugin *) 0x12ab620 <builtin_csv_plugin>
$21 = (st_mysql_plugin *) 0x12ab8e0 <builtin_heap_plugin>
$22 = (st_mysql_plugin *) 0x12b88e0 <builtin_myisam_plugin>
$23 = (st_mysql_plugin *) 0x12b90a0 <builtin_myisammrg_plugin>
```

##9.2 mysql_optional_plugins
```cpp
mysql_optional_plugins
--<builtin_blackhole_plugin>
-- <builtin_federated_plugin>
--<builtin_innobase_plugin>//明白了，都是INFORMATION_SCHEMA表
----INNODB_TRX
----INNODB_LOCKS
----INNODB_LOCK_WAITS
----INNODB_CMP	
----INNODB_CMP_RESET
----//INNODB_CMPMEM, INNODB_CMPMEM_RESET, INNODB_CMP_PER_INDEX, INNODB_CMP_PER_INDEX_RESET
----//INNODB_BUFFER_PAGE, INNODB_BUFFER_PAGE_LRU，INNODB_BUFFER_POOL_STATS， INNODB_METRICS，
----//INNODB_FT_DEFAULT_STOPWORD, INNODB_FT_DELETED, INNODB_FT_BEING_DELETED, INNODB_FT_CONFIG
----//INNODB_FT_INDEX_CACHE, INNODB_FT_INDEX_TABLE, INNODB_SYS_TABLES, INNODB_SYS_TABLESTATS
----//INNODB_SYS_INDEXES, INNODB_SYS_COLUMNS, INNODB_SYS_FIELDS, INNODB_SYS_FOREIGN, 
----//INNODB_SYS_FOREIGN_COLS, INNODB_SYS_TABLESPACES, INNODB_SYS_DATAFILES
--<builtin_perfschema_plugin>
--<builtin_partition_plugin>
```


#10.todo
```cpp
(gdb) bt
#0  plugin_dl_add (dl=dl@entry=0x7fffffffd8b0, report=report@entry=1) at /home/chenhui/mysql-5623-trunk/sql/sql_plugin.cc:484
#1  0x0000000000701a50 in plugin_load_list (list=0x13fd264 "ha_tokudb.so", argv=0x13fe4d8, argc=0x138f390 <remaining_argc>, tmp_root=0x7fffffffd8f0) at /home/chenhui/mysql-5623-trunk/sql/sql_plugin.cc:1621
#2  plugin_init (argc=argc@entry=0x138f390 <remaining_argc>, argv=0x13fe4d8, flags=flags@entry=0) at /home/chenhui/mysql-5623-trunk/sql/sql_plugin.cc:1409
#3  0x00000000005aa752 in init_server_components () at /home/chenhui/mysql-5623-trunk/sql/mysqld.cc:4898
#4  mysqld_main (argc=98, argv=0x13fe4d8) at /home/chenhui/mysql-5623-trunk/sql/mysqld.cc:5495
#5  0x00007ffff6bdbbd5 in __libc_start_main () from /opt/compiler/gcc-4.8.2/lib/libc.so.6
#6  0x000000000059ee95 in _start ()

(gdb) info br
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   <PENDING>          tokudb_init_func
2       breakpoint     keep y   0x0000000000701130 in plugin_init(int*, char**, int) at /home/chenhui/mysql-5623-trunk/sql/sql_plugin.cc:1276
        breakpoint already hit 1 time
3       breakpoint     keep y   0x000000000070166b in plugin_init(int*, char**, int) at /home/chenhui/mysql-5623-trunk/include/mysql/psi/mysql_thread.h:665
        breakpoint already hit 1 time
4       breakpoint     keep y   0x00000000005790fb in plugin_load(MEM_ROOT*, int*, char**) at /home/chenhui/mysql-5623-trunk/sql/sql_plugin.cc:1500
5       breakpoint     keep y   0x000000000070162b in plugin_init(int*, char**, int) at /home/chenhui/mysql-5623-trunk/sql/sql_plugin.cc:1401
        breakpoint already hit 1 time
```