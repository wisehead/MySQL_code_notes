#1.os_event_wait_time_low

```cpp
/**
Waits for an event object until it is in the signaled state or
a timeout is exceeded.
@return 0 if success, OS_SYNC_TIME_EXCEEDED if timeout was exceeded */
ulint os_event_wait_time_low(os_event_t event,   /*!< in/out: event to wait */
                             ulint time_in_usec, /*!< in: timeout in
                                                 microseconds, or
                                                 OS_SYNC_INFINITE_TIME */
                             int64_t reset_sig_count) /*!< in: zero or the value
                                                      returned by previous call
                                                      of os_event_reset(). */
{
  return (event->wait_time_low(time_in_usec, reset_sig_count));
}
```

#2.os_event::wait_time_low

```cpp
/**
Waits for an event object until it is in the signaled state or
a timeout is exceeded.
@param time_in_usec - timeout in microseconds, or OS_SYNC_INFINITE_TIME
@param reset_sig_count - zero or the value returned by previous call
        of os_event_reset().
@return 0 if success, OS_SYNC_TIME_EXCEEDED if timeout was exceeded */
ulint os_event::wait_time_low(ulint time_in_usec,
                              int64_t reset_sig_count) UNIV_NOTHROW {
  bool timed_out = false;

  struct timespec abstime;

  if (time_in_usec != OS_SYNC_INFINITE_TIME) {
    abstime = os_event::get_wait_timelimit(time_in_usec);
  } else {
    abstime.tv_nsec = 999999999;
    abstime.tv_sec = std::numeric_limits<time_t>::max();
  }

  ut_a(abstime.tv_nsec <= 999999999);

  mutex.enter();

  if (!reset_sig_count) {
    reset_sig_count = signal_count;
  }

  do {
    if (m_set || signal_count != reset_sig_count) {
      break;
    }

#ifndef _WIN32
    timed_out = timed_wait(&abstime);
#else
    timed_out = timed_wait(time_in_ms);
#endif /* !_WIN32 */

  } while (!timed_out);

  mutex.exit();
  return (timed_out ? OS_SYNC_TIME_EXCEEDED : 0);
}  
```

#3.os_event::timed_wait

```cpp
bool os_event::timed_wait(
    const timespec *abstime
) {
  int ret;

  ret = pthread_cond_timedwait(&cond_var, mutex, abstime);

  switch (ret) {
    case 0:
    case ETIMEDOUT:
      /* We play it safe by checking for EINTR even though
      according to the POSIX documentation it can't return EINTR. */
    case EINTR:
      break;

    default:
#ifdef UNIV_NO_ERR_MSGS
      ib::error()
#else
      ib::error(ER_IB_MSG_742)
#endif /* !UNIV_NO_ERR_MSGS */
          << "pthread_cond_timedwait() returned: " << ret << ": abstime={"
          << abstime->tv_sec << "," << abstime->tv_nsec << "}";
      ut_error;
  }

  return (ret == ETIMEDOUT);
}
```