#1.worker_main

```cpp
worker_main
--thread_group_t *thread_group = (thread_group_t *)param;
-=this_thread.thread_group= thread_group;
--for
----get_event
----handle_event
```