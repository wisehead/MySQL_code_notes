#1.timer_notify_thread_func

```cpp
timer_notify_thread_func
--my_thread_init();
--timer_notify_thread_id= (pid_t) syscall(SYS_gettid);
--while (1)
----if (sigwaitinfo(&set, &info) < 0)
------continue;
----if (info.si_signo == MY_TIMER_EVENT_SIGNO)
------timer= (my_timer_t*)info.si_value.sival_ptr;
------timer->notify_function(timer);
--------timer_callback
----else if (info.si_signo == MY_TIMER_KILL_SIGNO)
------break
--my_thread_end
```

#2.timer_callback

```cpp
timer_callback
--thd_timer= my_container_of(timer, THD_timer_info, timer)
--mysql_mutex_lock(&thd_timer->mutex);
--timer_notify(thd_timer)
----THD *thd= Global_THD_manager::get_instance()->find_thd(&find_thd_with_id);
----if (thd->killed != THD::KILL_CONNECTION)
------if ((thd->variables.ncdb_gcr_max_execution_time < thd->variables.max_execution_time 
          && thd->variables.ncdb_gcr_max_execution_time > 0 )
          || (thd->variables.max_execution_time == 0
          && thd->variables.ncdb_gcr_max_execution_time) > 0)
--------thd->awake(THD::KILL_TIMEOUT_NCDB);
------else
--------thd->awake(THD::KILL_TIMEOUT);          
--mysql_mutex_unlock(&thd_timer->mutex);

```

#3.THD::awake

```cpp
THD::awake
--if (this->m_server_idle && state_to_set == KILL_QUERY)
----//do nothing
--else
----killed= state_to_set;
--if (state_to_set != THD::KILL_QUERY && state_to_set != THD::KILL_TIMEOUT 
      && state_to_set != THD::KILL_TIMEOUT_NCDB)
----if (this != current_thd)
------if (active_vio)
--------vio_cancel(active_vio, SHUT_RDWR);
----if (!slave_thread)
------MYSQL_CALLBACK(scheduler, post_kill_notification, (this));
--if (state_to_set != THD::NOT_KILLED)
----ha_kill_connection
------plugin_foreach(thd, kill_handlerton, MYSQL_STORAGE_ENGINE_PLUGIN, 0)
------kill_connection
--------innobase_kill_connection
```