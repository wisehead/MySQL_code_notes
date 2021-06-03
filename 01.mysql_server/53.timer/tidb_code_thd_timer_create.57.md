#1.thd_timer_create

```cpp
thd_timer_create
--thd_timer= (THD_timer_info *) my_malloc
--mysql_mutex_init(key_thd_timer_mutex, &thd_timer->mutex, MY_MUTEX_INIT_FAST);
--thd_timer->timer.notify_function= timer_callback;
--my_timer_create
----memset(&sigev, 0, sizeof(sigev));
----return timer_create(CLOCK_MONOTONIC, &sigev, &timer->id);

```

#2.thd_timer_set

```cpp
thd_timer_set
--thd_timer_create
--thd_timer->thread_id= thd->thread_id();
--my_timer_set(&thd_timer->timer, time)
----timer_settime(timer->id, 0, &spec, NULL)
----
```
#3.set_statement_timer

```cpp
set_statement_timer
--thd->timer= thd_timer_set(thd, thd->timer_cache, max_execution_time);
--thd->timer_cache= NULL;

```