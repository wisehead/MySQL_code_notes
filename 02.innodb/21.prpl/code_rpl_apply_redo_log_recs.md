#1.rpl_apply_redo_log_recs

```cpp
rpl_apply_redo_log_recs
--block->rpl_log_applied = true;//todo this flag
--rpl_addr_t* rpl_addr = block->rpl_addr;//todo: this address, seems like a queue.
--mtr_start(&mtr);
--mtr_set_log_mode(&mtr, MTR_LOG_NONE);
--rw_lock_x_lock_move_ownership(&block->lock);//todo: for what
--buf_page_get_known_nowait(RW_X_LATCH, block, BUF_KEEP_OLD,__FILE__, __LINE__, &mtr);
--buf_block_dbg_add_level(block, SYNC_NO_ORDER_CHECK);
--//for
----TiDB_rpl_sys::apply_log_recs
--//end for
--mtr.discard_modifications();
--mtr_commit(&mtr);
```