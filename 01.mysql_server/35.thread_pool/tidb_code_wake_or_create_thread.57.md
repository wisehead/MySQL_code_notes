#1.wake_or_create_thread

```cpp
wake_or_create_thread
--wake_thread
----*thread = thread_group->waiting_threads.front();
----thread->woken= true;
----mysql_cond_signal(&thread->cond);
--if (thread_group->active_thread_count == 0)
----create_worker(thread_group)
--if (time_since_last_thread_created > microsecond_throttling_interval(thread_group))
----create_worker
```

#2.caller

```
- check_stall
- queue_put
- wait_begin
```