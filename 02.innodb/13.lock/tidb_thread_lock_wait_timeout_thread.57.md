#1.lock_wait_timeout_thread

```cpp
lock_wait_timeout_thread
--while (srv_shutdown_state < SRV_SHUTDOWN_CLEANUP)
----lock_wait_check_slots_for_timeouts
------for (auto slot = lock_sys->waiting_threads; slot < lock_sys->last_slot;++slot)
--------lock_wait_check_and_cancel
----------lock_cancel_waiting_and_release
------------if (lock_get_type_low(lock) == LOCK_REC)
--------------lock_rec_dequeue_from_page
------------else
--------------lock_table_dequeue
----------------lock = UT_LIST_GET_NEXT(tab_lock.locks, in_lock)
----------------lock_table_remove_low
------------------locksys::remove_from_trx_locks(lock)
--------------------UT_LIST_REMOVE(lock->trx->lock.trx_locks, lock);
------------------ut_list_remove(table->locks, lock, TableLockGetNode())
------------lock_reset_wait_and_release_thread_if_suspended
--------------thr = que_thr_end_lock_wait(lock->trx)
----------------thr = trx->lock.wait_thr;
----------------que_thr_move_to_run_state
----------------trx->lock.que_state = TRX_QUE_RUNNING;
--------------lock_reset_lock_and_trx_wait
----------------lock->trx->lock.wait_lock = NULL;
----------------lock->type_mode &= ~LOCK_WAIT;
--------------lock_wait_release_thread_if_suspended
----------------os_event_set(thr->slot->event);//!!!!!!!!!!!!!!!!!!!!!!!!!! 在这里释放，终于找到了
----lock_wait_update_schedule_and_check_for_deadlocks
----os_event_wait_time_low(event, 1000000, sig_count);
----sig_count = os_event_reset(event);
```