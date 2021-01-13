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