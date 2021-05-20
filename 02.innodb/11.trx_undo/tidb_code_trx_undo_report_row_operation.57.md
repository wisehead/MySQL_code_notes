#1.trx_undo_report_row_operation

```cpp
/***********************************************************************//**
Writes information to an undo log about an insert, update, or a delete marking
of a clustered index record. This information is used in a rollback of the
transaction and in consistent reads that must look to the history of this
transaction.
@return DB_SUCCESS or error code */

trx_undo_report_row_operation
--if (trx->read_only || is_temp_table)
----if (trx->rsegs.m_noredo.rseg == 0)
------trx_assign_rseg(trx)
--dict_disable_redo_if_temporary(index->table, &mtr);
--trx_undo_assign_undo
----trx_undo_reuse_cached
------trx_undo_header_create
--------trx_undo_header_create_log
----------mlog_write_initial_log_record//MLOG_UNDO_HDR_CREATE
```

#2.caller

```cpp
- btr_cur_ins_lock_and_undo
- btr_cur_upd_lock_and_undo
- btr_cur_del_mark_set_clust_rec

```