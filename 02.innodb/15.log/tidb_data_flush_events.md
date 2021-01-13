#1.flush_events

```cpp
struct log_t {
    /** Unaligned pointer to array with events, which are used for
    notifications sent from the log flush notifier thread to user threads.
    The notifications are sent when flushed_to_disk_lsn is advanced.
    User threads wait for flushed_to_disk_lsn >= lsn, for some lsn.
    Log flusher advances the flushed_to_disk_lsn and notifies the
    log flush notifier, which notifies all users interested in nearby lsn
    values (lsn belonging to the same log block). Note that false
    wake-ups are possible, in which case user threads simply retry
    waiting. */
    os_event_t* flush_events;
}    
```

#2.log_allocate_flush_events

```cpp
caller:
- log_init


log_allocate_flush_events
--n = srv_log_flush_events
--log_sys->flush_events_size = n
--log_sys->flush_events = UT_NEW_ARRAY_NOKEY(os_event_t, n)
--for (ulint i = 0; i < log_sys->flush_events_size; ++i)
----log_sys->flush_events[i] = os_event_create(NULL)
```

#3.log_deallocate_flush_events

```cpp

log_deallocate_flush_events
--for (ulint i = 0; i < log_sys->flush_events_size; ++i)
----os_event_destroy(log_sys->flush_events[i])
--UT_DELETE_ARRAY(log_sys->flush_events)
```


#4.log_wait_for_flush

```cpp
caller:
- log_write_up_to


log_wait_for_flush
--log_wake_flusher(log);
--log_max_spins_when_waiting_in_user_thread
--stop_condition//lambda
--slot = (lsn - 1) / OS_FILE_LOG_BLOCK_SIZE & (log_sys->flush_events_size - 1)
--os_event_wait_for(log_sys->flush_events[slot], max_spins,srv_log_wait_for_flush_timeout, stop_condition);
```