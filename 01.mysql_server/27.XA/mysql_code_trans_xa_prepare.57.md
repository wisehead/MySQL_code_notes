#1.trans_xa_prepare

```cpp
trans_xa_prepare
--ha_prepare
----commit_owned_gtids
----innobase_xa_prepare
------thd_get_xid(thd, (MYSQL_XID*) trx->xid);
------trx_prepare_for_mysql
--------trx_start_if_not_started_xa_low
--------trx_prepare
----------if (trx->rsegs.m_redo.rseg != NULL && trx_is_redo_rseg_updated(trx))
------------trx_prepare_low
--------------trx_undo_set_state_at_prepare
----------------undo_page = trx_undo_page_get(page_id_t(undo->space, undo->hdr_page_no)
----------------seg_hdr = undo_page + TRX_UNDO_SEG_HDR;
----------------undo->state = TRX_UNDO_PREPARED;//修改内存数据结构
----------------undo->xid   = *trx->xid;//修改内存数据结构
----------------mlog_write_ulint(seg_hdr + TRX_UNDO_STATE, undo->state, MLOG_2BYTES, mtr);//落盘
----------------mlog_write_ulint(undo_header + TRX_UNDO_XID_EXISTS,TRUE, MLOG_1BYTE, mtr);
----------------trx_undo_write_xid(undo_header, &undo->xid, mtr);
--------------mtr_commit(&mtr)
----------trx->state = TRX_STATE_PREPARED;
----------trx_flush_log_if_needed(lsn, trx);
----gtid_state_commit_or_rollback
--xid_state->set_state(XID_STATE::XA_PREPARED);
```