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
--------------thd_get_cache_mngr
----------------thd_get_ha_data(thd, binlog_hton);
------------------thd_ha_data
--------------------return (void **) &thd->ha_data[hton->slot].ha_ptr;
------------is_transactional= start_event->is_using_trans_cache();
------------binlog_cache_mngr *cache_mngr= thd_get_cache_mngr(thd);
------------binlog_cache_data *cache_data= cache_mngr->get_binlog_cache_data(is_transactional);
------------register_binlog_handler
--------------binlog_trans_log_savepos
--------------trans_register_ha
----------------Ha_trx_info *knownn_trans= trn_ctx->ha_trx_info(trx_scope);
----------------ha_info= thd->ha_data[ht_arg->slot].ha_info + (all ? 1 : 0);
----------------ha_info->register_ha(knownn_trans, ht_arg);
----------------trn_ctx->xid_state()->set_query_id(thd->query_id);
--------------thd->ha_data[binlog_hton->slot].ha_info[0].set_trx_read_write();
------------if (cache_data->is_binlog_empty())
--------------cache_data->write_event(thd, &qinfo)
----------------？？？？
----//inner for
--//end for
```