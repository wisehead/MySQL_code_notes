#1.struct thread_group_t

```cpp
struct thread_group_t
{
  mysql_mutex_t mutex;
  connection_queue_t queue;
  connection_queue_t high_prio_queue;
  worker_list_t waiting_threads;
  worker_thread_t *listener;
  pthread_attr_t *pthread_attr;
  int pollfd;
  int thread_count;
  int active_thread_count;
  int connection_count;
  int waiting_thread_count;
  int dump_thread_count;
  /* Stats for the deadlock detection timer routine.*/
  int io_event_count;
  int queue_event_count;
  ulonglong last_thread_creation_time;
  int shutdown_pipe[2];
  bool shutdown;
  bool stalled;
} MY_ALIGNED(512);

```