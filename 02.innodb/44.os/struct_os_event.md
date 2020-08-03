#1.struct os_event

```cpp
/** InnoDB condition variable. */
struct os_event {

 private:
  bool m_set;           /*!< this is true when the
                        event is in the signaled
                        state, i.e., a thread does
                        not stop if it tries to wait
                        for this event */
  int64_t signal_count; /*!< this is incremented
                        each time the event becomes
                        signaled */
  EventMutex mutex;     /*!< this mutex protects
                        the next fields */

  os_cond_t cond_var; /*!< condition variable is
                      used in waiting for the event */

#ifndef _WIN32
  /** Attributes object passed to pthread_cond_* functions.
  Defines usage of the monotonic clock if it's available.
  Initialized once, in the os_event::global_init(), and
  destroyed in the os_event::global_destroy(). */
  static pthread_condattr_t cond_attr;

  /** True iff usage of the monotonic clock has been successfuly
  enabled for the cond_attr object. */
  static bool cond_attr_has_monotonic_clock;
#endif /* !_WIN32 */
  static bool global_initialized;

#ifdef UNIV_DEBUG
  static std::atomic_size_t n_objects_alive;
#endif /* UNIV_DEBUG */

 public:
  event_iter_t event_iter; /*!< For O(1) removal from
                           list */
};                           
```