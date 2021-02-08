#1.lock_wait_timeout_thread

```cpp
lock_wait_timeout_thread
--while (srv_shutdown_state < SRV_SHUTDOWN_CLEANUP)
----lock_wait_check_slots_for_timeouts
------for (auto slot = lock_sys->waiting_threads; slot < lock_sys->last_slot;++slot)
--------lock_wait_check_and_cancel
----lock_wait_update_schedule_and_check_for_deadlocks
----os_event_wait_time_low(event, 1000000, sig_count);
----sig_count = os_event_reset(event);
```