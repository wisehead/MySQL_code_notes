#latest\_gtid\_desc
```cpp
caller of latest_gtid_desc:

- ncdb_get_info_for_slave_startup
- trx_commit_low
- trx_apply_commit_log
- trx_slave_flush_ids
```

#1.struct trx_sys_t
```cpp
struct trx_sys_t {
...
...    
        Gtid_desc       latest_gtid_desc;
                                        /*!< Latest trx commit gtid in master;
                                        protect by ids_mutex
                                        * update when trx commit
                                        (trx_commit_low)
                                        * read when slave login
                                        (NCDB_Master_Info::ncdb_get_info_for_slave_startup)

                                        Latest redo log apply gtid in slave;
                                        protect by ids_mutex
                                        * update when apply commit log
                                        (trx_apply_commit_log)
                                        * read when make a fresh readview
                                        (trx_slave_flush_ids) */

        Gtid_info       slave_latest_gtid_info;
                                        /*!< Latest readview gtid in slave,
                                        protect by readview mutex
                                        * update when make a fresh readview
                                        (trx_slave_flush_ids)
                                        * read when open read view
                                        (ReadView::prepare) */
...
...                                        
}
```

#2. ncdb_get_info_for_slave_startup

```cpp
NCDB_Master_Info::ncdb_get_info_for_slave_startup
--gtid_state->get_server_sidno();
--gtid_state->get_last_executed_gno(sidno)
----Gtid_set::get_last_gno
```