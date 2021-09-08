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
----if (io_poll_wait(thread_group->pollfd, &nev, 1, 0) == 1)
------connection = (connection_t *)native_event_get_userdata(&nev);
------if (connection_is_high_prio(connection))
--------connection->tickets--;
------else if (too_many_busy_threads(thread_group))
--------thread_group->queue.push_back(connection);
----thread_group->waiting_threads.push_front(current_thread);
----mysql_cond_wait(&current_thread->cond, &thread_group->mutex);
```