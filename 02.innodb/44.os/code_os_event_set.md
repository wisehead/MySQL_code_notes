#1.os_event_set

```cpp
/**
Sets an event semaphore to the signaled state: lets waiting threads
proceed. */
void os_event_set(os_event_t event) /*!< in/out: event to set */
{
  event->set();
}
```


#2.os_event::set

```cpp
  /** Set the event */
  void set() UNIV_NOTHROW {
    mutex.enter();

    if (!m_set) {
      broadcast();
    }

    mutex.exit();
  }
```

#3.os_event::broadcast

```cpp
  /**
  Wakes all threads waiting for condition variable */
  void broadcast() UNIV_NOTHROW {
    m_set = true;
    ++signal_count;

#ifdef _WIN32
    WakeAllConditionVariable(&cond_var);
#else
    {
      int ret;

      ret = pthread_cond_broadcast(&cond_var);
      ut_a(ret == 0);
    }
#endif /* _WIN32 */
  }
```