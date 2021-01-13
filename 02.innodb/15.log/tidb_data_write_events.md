#1.write_events

```cpp
in struct log_t {
    /** Unaligned pointer to array with events, which are used for
    notifications sent from the log write notifier thread to user threads.
    The notifications are sent when write_lsn is advanced. User threads
    wait for write_lsn >= lsn, for some lsn. Log writer advances the
    write_lsn and notifies the log write notifier, which notifies all users
    interested in nearby lsn values (lsn belonging to the same log block).
    Note that false wake-ups are possible, in which case user threads
    simply retry waiting. */
    os_event_t  *write_events;
}
```

#2.log_allocate_write_events

```cpp
caller:
-log_init

log_allocate_write_events
--n = srv_log_write_events
--log_sys->write_events = UT_NEW_ARRAY_NOKEY(os_event_t, n);
--for (ulint i = 0; i < log_sys->write_events_size; ++i)
----log_sys->write_events[i] = os_event_create("NULL");

```

#3.log_deallocate_write_events

```cpp
caller:
-log_shutdown

log_deallocate_write_events
--for (ulint i = 0; i < log_sys->write_events_size; ++i)
----os_event_destroy(log_sys->write_events[i]);
--UT_DELETE_ARRAY(log_sys->write_events)
```

#4.log_wait_for_write

```cpp
caller:
- log_write_up_to

log_wait_for_write
--log_wake_writer(log);
----if (log.writer_wait.load())
------os_event_set(log.write_event);
--log_max_spins_when_waiting_in_user_thread
--stop_condition//lambda
--slot = (lsn - 1) / OS_FILE_LOG_BLOCK_SIZE & (log.write_events_size - 1)
--os_event_wait_for(log.write_events[slot], max_spins,srv_log_wait_for_write_timeout, stop_condition);
```

#5.notify_about_advanced_write_lsn

```cpp
caller:
- log_write_run_new
- log_write_run_old


notify_about_advanced_write_lsn
--log_wake_flusher
--if (first_slot == last_slot)
----os_event_set(log.write_events[first_slot]);//OR
--else
----os_event_set(log.write_notifier_event);
```


#6.log_write_notifier

```cpp
DECLARE_THREAD(log_write_notifier)
--os_event_wait(log.write_notifier_event)
--while (true)
----stop_condition//lambda
----waiting.wait(stop_condition)
----notified_up_to_lsn = ut_uint64_align_up(write_lsn, OS_FILE_LOG_BLOCK_SIZE);
----while (lsn <= notified_up_to_lsn)
------slot = (lsn - 1) / OS_FILE_LOG_BLOCK_SIZE & (log.write_events_size - 1);
------lsn += OS_FILE_LOG_BLOCK_SIZE;
------os_event_set(log.write_events[slot]);
----//end while
----lsn = write_lsn + 1;
--//end while(true)

```