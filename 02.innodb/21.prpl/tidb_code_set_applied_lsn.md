#1.set_applied_lsn

```cpp
caller:
--TiDB_rpl_sys::parse_log_recs
--TiDB_rpl_sys::log_scan_for_page_invalidation


TiDB_rpl_sys::set_applied_lsn
tidb_node::set_applied_lsn

```


#2. get_applied_lsn

```cpp
//example
btr_cur_page_is_stale
{
	lsn_t   applied_lsn = rpl_sys->get_applied_lsn();
}
```