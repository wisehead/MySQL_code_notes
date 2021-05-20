#1.trx_assign_rseg

```cpp
trx_assign_rseg
--trx->rsegs.m_noredo.rseg = trx_assign_rseg_low(srv_undo_logs, srv_undo_tablespaces, TRX_RSEG_TYPE_NOREDO);
--if (trx->id == 0)
----trx->id = trx_sys_get_new_trx_id();
----if (!ncdb_slave_mode())
------trx_sys->rw_trx_ids.push_back(trx->id);
----trx_sys_rw_trx_add(trx, false);
```

#2.caller

```cpp
- trx_undo_report_row_operation
- trx_start_if_not_started_xa_low
```