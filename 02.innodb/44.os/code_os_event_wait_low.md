#1.os_event_wait_low

```cpp
/**
Waits for an event object until it is in the signaled state.

Where such a scenario is possible, to avoid infinite wait, the
value returned by os_event_reset() should be passed in as
reset_sig_count. */
void os_event_wait_low(os_event_t event,        /*!< in: event to wait */
                       int64_t reset_sig_count) /*!< in: zero or the value
                                                returned by previous call of
                                                os_event_reset(). */
{
  event->wait_low(reset_sig_count);
}
```

#2.os_event::wait_low

```cpp
/**
Waits for an event object until it is in the signaled state.

Typically, if the event has been signalled after the os_event_reset()
we'll return immediately because event->m_set == true.
There are, however, situations (e.g.: sync_array code) where we may
lose this information. For example:

thread A calls os_event_reset()
thread B calls os_event_set()   [event->m_set == true]
thread C calls os_event_reset() [event->m_set == false]
thread A calls os_event_wait()  [infinite wait!]
thread C calls os_event_wait()  [infinite wait!]

Where such a scenario is possible, to avoid infinite wait, the
value returned by reset() should be passed in as
reset_sig_count. */
void os_event::wait_low(int64_t reset_sig_count) UNIV_NOTHROW {
  mutex.enter();

  if (!reset_sig_count) {
    reset_sig_count = signal_count;
  }

  while (!m_set && signal_count == reset_sig_count) {
    wait();

    /* Spurious wakeups may occur: we have to check if the
    event really has been signaled after we came here to wait. */
  }

  mutex.exit();
}

```

#3.os_event::wait

```cpp
  /**
  Wait on condition variable */
  void wait() UNIV_NOTHROW {
#ifdef _WIN32
    if (!SleepConditionVariableCS(&cond_var, mutex, INFINITE)) {
      ut_error;
    }
#else
    {
      int ret;

      ret = pthread_cond_wait(&cond_var, mutex);
      ut_a(ret == 0);
    }
#endif /* _WIN32 */
  }
```