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
----else if (info.si_signo == MY_TIMER_KILL_SIGNO)
------break
--my_thread_end
```