#1.struct connection_t

```cpp
struct connection_t
{
  THD *thd;
  thread_group_t *thread_group;
  connection_t *next_in_queue;
  connection_t **prev_in_queue;
  ulonglong abs_wait_timeout;
  bool logged_in;
  bool bound_to_poll_descriptor;
  bool waiting;
  uint tickets;
  bool dump_thread;
};

```