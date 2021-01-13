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