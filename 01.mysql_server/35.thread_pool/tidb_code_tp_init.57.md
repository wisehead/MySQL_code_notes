#1.tp_init

```cpp
tp_init
--for(uint i = 0; i < array_elements(all_groups); i++)
----thread_group_init(&all_groups[i], get_connection_attrib());
--tp_set_threadpool_size(threadpool_size);
--start_timer(&pool_timer)

```