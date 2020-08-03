#1.os_event_reset

```cpp
/**
Resets an event semaphore to the nonsignaled state. Waiting threads will
stop to wait for the event.
The return value should be passed to os_even_wait_low() if it is desired
that this thread should not wait in case of an intervening call to
os_event_set() between this os_event_reset() and the
os_event_wait_low() call. See comments for os_event_wait_low().
@return current signal_count. */
int64_t os_event_reset(os_event_t event) /*!< in/out: event to reset */
{
  return (event->reset());
}
```


#2.os_event::reset


```cpp
  int64_t reset() UNIV_NOTHROW {
    mutex.enter();

    if (m_set) {
      m_set = false;
    }

    int64_t ret = signal_count;

    mutex.exit();

    return (ret);
  }
```