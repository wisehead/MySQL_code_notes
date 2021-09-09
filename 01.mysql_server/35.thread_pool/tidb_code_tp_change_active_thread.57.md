#1.tp_change_active_thread

```cpp
tp_change_active_thread
--connection_t *con = (connection_t *)thd->event_scheduler.data;
--if (inc)
----group->dump_thread_count--;
----con->dump_thread = false;
----group->active_thread_count++;
--else
----group->dump_thread_count++;
----con->dump_thread = true;
----group->active_thread_count--;
```

#2. caller

dispatch_command