#1.binlog_log_row

```cpp
caller:
- ha_write_row
- ha_update_row
- ha_delete_row

binlog_log_row
--check_table_binlog_row_based
--write_locked_table_maps
----locks[0]= thd->extra_lock;
----locks[1]= thd->lock;
----for (uint i= 0 ; i < sizeof(locks)/sizeof(*locks) ; ++i )
------MYSQL_LOCK const *const lock= locks[i];
------TABLE **const end_ptr= lock->table + lock->table_count;
------for (TABLE **table_ptr= lock->table ;table_ptr != end_ptr ;++table_ptr)
--------THD::binlog_write_table_map
----------binlog_start_trans_and_stmt
------------THD::binlog_setup_trx_data
----//inner for
--//end for
```