#1.innobase_node_stats

```cpp
innobase_node_stats
--ncdb_context->get_nmgr()->get_node_stats(stats)//node_manager::get_node_stats
----NODE_STATS* node_stats = ncdb_context->get_node_stats();
    node_stats->lock_stats();
    new(stats) NODE_STATS(*node_stats);
    node_stats->unlock_stats();
----lock_nmgr
----stats->master.write_lsn = log_sys->write_lsn.load();
----stats->master.log_lsn = LOG_SYS_GET_LSN();
----unlock_nmgr();
```

#2.register

```cpp
innobase_init
--innobase_hton->node_stats = innobase_node_stats;
```


#3.caller

```cpp
      LEX_CSTRING engine_name= {C_STRING_WITH_LEN("innodb")};
      plugin_ref plugin= ha_resolve_by_name_raw(thd, engine_name);
      handlerton* hton= plugin_data<handlerton*>(plugin);
      NODE_STATS stats;
      hton->node_stats(hton, &stats);
```