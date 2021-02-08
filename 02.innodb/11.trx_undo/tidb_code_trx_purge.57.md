#1. trx_purge

```cpp
trx_purge
--trx_purge_attach_undo_recs
----thr = UT_LIST_GET_FIRST(purge_sys->query->thrs);
----for (;;)
------node = (purge_node_t*) thr->child;
------purge_rec->undo_rec = trx_purge_fetch_next_rec
------ib_vector_push(node->undo_recs, purge_rec);
------thr = UT_LIST_GET_NEXT(thrs, thr)
----//end for
--if (n_purge_threads > 1)
----for (i = 0; i < n_purge_threads - 1; ++i)
------que_fork_scheduler_round_robin
--------if (thr == NULL)
----------thr = UT_LIST_GET_FIRST(fork->thrs);
--------else
----------thr = UT_LIST_GET_NEXT(thrs, thr);
--------fork->state = QUE_FORK_ACTIVE;
--------que_thr_init_command
----------thr->run_node = thr;
----------thr->prev_node = thr->common.parent;
----------que_thr_move_to_run_state
------srv_que_task_enqueue_low
--------UT_LIST_ADD_LAST(srv_sys->tasks, thr);
--------srv_release_threads(SRV_WORKER, 1)
----//end for
----goto run_synchronously;
----que_run_threads(thr);
----if (n_purge_threads > 1)
------trx_purge_wait_for_workers_to_complete
--------n_submitted = purge_sys->n_submitted;
--------while (!os_compare_and_swap_ulint(&purge_sys->n_completed, n_submitted, n_submitted))
----------if (srv_get_task_queue_length() > 0)
------------srv_release_threads(SRV_WORKER, 1);
----------os_thread_yield


```