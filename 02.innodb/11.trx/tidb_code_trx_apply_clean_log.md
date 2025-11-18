#1.trx_apply_clean_log

```cpp
caller:
--recv_parse_or_apply_log_rec_body
--TiDB_rpl_sys::parse_or_apply_log_rec_body

trx_apply_clean_log
--mutex_enter(&trx_sys->ids_mutex);
--trx_sys->slave_clean_id = trx_id;
--mutex_exit(&trx_sys->ids_mutex);
```