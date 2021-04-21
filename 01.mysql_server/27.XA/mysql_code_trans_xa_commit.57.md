#1.trans_xa_commit

```cpp
trans_xa_commit
--if (!xid_state->has_same_xid(m_xid))
--if (xid_state->has_state(XID_STATE::XA_PREPARED) &&  m_xa_opt == XA_NONE)
----commit_owned_gtids
----MDL_context::acquire_lock
----TC_LOG_DUMMY::commit
------ha_commit_low
--------THD::rpl_unflag_detached_engine_ha_data
--------innobase_commit
----------thd_binlog_pos
----------trx->flush_log_later = true;
----------innobase_commit_low
------------trx_commit_for_mysql
--------------switch (trx->state)
----------------trx_update_mod_tables_timestamp
----------------trx_commit(trx)
----------trx_commit_complete_for_mysql//flush redo logs.
----------innobase_srv_conc_force_exit_innodb(trx);
--------Transaction_ctx::invalidate_changed_tables_in_cache
--------Transaction_ctx::cleanup
--cleanup_trans_state
--xid_state->set_state(XID_STATE::XA_NOTR);
--xid_state->unset_binlogged();
```