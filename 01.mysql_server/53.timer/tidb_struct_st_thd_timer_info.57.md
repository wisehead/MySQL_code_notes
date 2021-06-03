#1.struct st_thd_timer_info


```cpp
struct st_thd_timer_info
{
  my_thread_id thread_id;
  my_timer_t timer;
  mysql_mutex_t mutex;
  bool destroy;
};

```