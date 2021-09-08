#1.fix_threadpool_size

```cpp
fix_threadpool_size
--tp_set_threadpool_size
----for(uint i=0; i< size; i++)
------thread_group_t *group= &all_groups[i];
------group->pollfd= io_poll_create();
```