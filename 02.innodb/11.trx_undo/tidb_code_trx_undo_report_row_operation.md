#1.trx_undo_report_row_operation

```cpp
trx_undo_report_row_operation
--trx_undo_assign_undo
----trx_undo_reuse_cached
------trx_undo_header_create
--------trx_undo_header_create_log
----------mlog_write_initial_log_record//MLOG_UNDO_HDR_CREATE
```