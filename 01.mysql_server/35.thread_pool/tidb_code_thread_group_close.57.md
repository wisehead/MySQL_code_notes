#1.thread_group_close

```cpp
thread_group_close
--if (thread_group->thread_count == 0)
----thread_group_destroy(thread_group)
--thread_group->shutdown= true;
--thread_group->listener= NULL;
--pipe(thread_group->shutdown_pipe)
--io_poll_associate_fd(thread_group->pollfd, thread_group->shutdown_pipe[0], NULL)
--write(thread_group->shutdown_pipe[1], &c, 1)//listener收到这个信号，do sth
--while(wake_thread(thread_group) == 0)

```

#2.caller

tp_end
