#1. trx_purge

```cpp
trx_purge
--que_fork_scheduler_round_robin
----thr = UT_LIST_GET_FIRST(fork->thrs);
----que_thr_init_command
------thr->run_node = thr;
------thr->prev_node = thr->common.parent;
------que_thr_move_to_run_state\
--srv_que_task_enqueue_low
```