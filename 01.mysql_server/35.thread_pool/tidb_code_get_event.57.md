#1. get_event

```cpp
get_event
--for(;;)
----oversubscribed = too_many_active_threads
------(thread_group->active_thread_count >= 1 + (int)threadpool_oversubscribe && !thread_group->stalled);
----connection = queue_get(thread_group);
------thread_group->high_prio_queue.front()
------thread_group->queue.front()
----if(!oversubscribed && !thread_group->listener)
------thread_group->listener = current_thread;
------connection = listener(current_thread, thread_group);

```