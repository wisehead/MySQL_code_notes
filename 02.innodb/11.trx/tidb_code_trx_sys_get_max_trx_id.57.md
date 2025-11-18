#1.trx_sys_get_max_trx_id

```cpp
trx_sys_get_max_trx_id
--return(trx_sys->max_trx_id)
```

#2.caller

```cpp
- lock_check_trx_id_sanity
- lock_release
- lock_print_info_summary
- page_validate
- MVCC::view_open
- row_vers_impl_x_locked_low
```