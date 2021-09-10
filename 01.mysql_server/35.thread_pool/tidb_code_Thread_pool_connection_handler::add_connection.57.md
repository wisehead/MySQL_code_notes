#1.Thread_pool_connection_handler::add_connection

```CPP
Thread_pool_connection_handler::add_connection
--THD *thd = channel_info->create_thd();
--alloc_connection(thd)
--Global_THD_manager::get_instance()->add_thd(thd);
--thd->event_scheduler.data= connection;
--thread_group_t *group= &all_groups[thd->thread_id() % group_count];
--connection->thread_group= group;
--queue_put(group, connection);
----connection->tickets = connection->thd->variables.threadpool_high_prio_tickets;
----thread_group->queue.push_back(connection);
----if (thread_group->active_thread_count == 0)
------wake_or_create_thread(thread_group);
```

#2.caller

Connection_handler_manager::process_new_connection