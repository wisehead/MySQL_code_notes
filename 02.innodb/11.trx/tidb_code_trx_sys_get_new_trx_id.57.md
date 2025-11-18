#1.trx_sys_get_new_trx_id


```cpp

trx_sys_get_new_trx_id
--if (ncdb_slave_mode())//for slave temporary table.
----return trx_sys->mvcc->get_oldest_no(false);
--if (!(trx_sys->max_trx_id % TRX_SYS_TRX_ID_WRITE_MARGIN))
----trx_sys_flush_max_trx_id
--return(trx_sys->max_trx_id++)
```

#2.caller

```cpp
- trx_assign_rseg
- trx_start_low
- trx_serialisation_number_get
- trx_set_rw_mode
```