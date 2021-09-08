#1.listener

```cpp
listener
--for(;;)
----io_poll_wait
------epoll_wait
---- for(int i = (listener_picks_event) ? 1 : 0; i < cnt ; i++)
    {
      connection_t *c = (connection_t *) native_event_get_userdata(&ev[i]);
      if (connection_is_high_prio(c))
        thread_group->high_prio_queue.push_back(c);
      else
      {
        c->tickets = c->thd->variables.threadpool_high_prio_tickets;
        thread_group->queue.push_back(c);
      }
    }
----if (listener_picks_event)
------retval= (connection_t *)native_event_get_userdata(&ev[0]);//listener自己先处理一条
----if(thread_group->active_thread_count == 0)
------wake_thread//唤醒woker开始干活
--------worker_thread_t *thread = thread_group->waiting_threads.front();
--------thread->woken= true;
--------mysql_cond_signal(&thread->cond)
------if(thread_group->thread_count == 1)
--------create_worker
----------mysql_thread_create;
```