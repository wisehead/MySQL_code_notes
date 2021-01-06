#1.thread trx_rollback_or_clean_all_recovered

```cpp
caller:
innobase_init
--innobase_start_or_create_for_mysql
--recv_recovery_rollback_active

/*******************************************************************//**
Rollback or clean up any incomplete transactions which were
encountered in crash recovery.  If the transaction already was
committed, then we clean up a possible insert undo log. If the
transaction was not yet committed, then we roll it back.
Note: this is done in a background thread.
@return a dummy parameter */

DECLARE_THREAD(trx_rollback_or_clean_all_recovered)
--trx_rollback_or_clean_recovered
----while (trx != NULL)
------trx_sys_mutex_enter
------trx_rollback_resurrected
--------switch (state)
--------case TRX_STATE_COMMITTED_IN_MEMORY:
----------trx_cleanup_at_db_startup
------------if (trx->rsegs.m_redo.insert_undo != NULL)
--------------trx_undo_insert_cleanup
------------UT_LIST_REMOVE(trx_sys->rw_trx_list, trx);
------------trx->state = TRX_STATE_NOT_STARTED;
----------trx_free_resurrected
--------case TRX_STATE_ACTIVE:
----------trx_rollback_active
----------trx_free_for_background
--------//end switch
------trx_sys_mutex_exit
----//end while
--trx_rollback_or_clean_is_active = false;
--trx_write_clean_log
--my_thread_end
--os_thread_exit

```