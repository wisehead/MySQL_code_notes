#1. que_thr_init_command

```cpp
caller:
- que_fork_scheduler_round_robin
- que_fork_start_command


que_thr_init_command
--
```

#2. que_fork_scheduler_round_robin


```cpp
caller:
- trx_purge
```

#3. que_fork_start_command

```cpp
caller:
- fts_eval_sql//text search
- lock_table_for_trx
- que_eval_sql//最主干的流程
- row_import_update_index_root
- row_merge_create_index_graph
- row_create_table_for_mysql
- row_create_index_for_mysql
- row_mysql_lock_table
- trx_rollback_to_savepoint_low
- trx_rollback_active
- trx_rollback_start
```

#4. fts\_eval\_sql

```cpp
//fts_parse_sql生成 graph
fts_config_get_value
--graph = fts_parse_sql
----graph = pars_sql(info, str);
--fts_eval_sql(trx, graph)

```

#5.lock_table_for_trx

```cpp
lock_table_for_trx
--node = sel_node_create(heap)
----node->common.type = QUE_NODE_SELECT;
----node->state = SEL_NODE_OPEN;
--thr = pars_complete_graph_for_exec(node, trx, heap, NULL)
----fork =que_fork_create
----thr = que_thr_create
----thr->child = node;
----que_node_set_parent(node, thr)
--thr->graph->state = QUE_FORK_ACTIVE;
--que_fork_get_first_thr
--que_thr_move_to_run_state_for_mysql
----thr->is_active = TRUE;
----thr->state = QUE_THR_RUNNING
--lock_table
----if (wait_for != NULL)
------lock_table_enqueue_waiting(mode | flags, table, thr)
--------check que_thr_stop
--if (UNIV_LIKELY(err == DB_SUCCESS))
----que_thr_stop_for_mysql_no_error
------thr->state = QUE_THR_COMPLETED;
------thr->is_active = FALSE;
--else 
----que_thr_stop_for_mysql
----if (err != DB_QUE_THR_SUSPENDED)//期望返回 DB_LOCK_WAIT
------row_mysql_handle_errors
--------case DB_LOCK_WAIT:
--------trx_kill_blocking
--------lock_wait_suspend_thread
----------lock_wait_table_reserve_slot
------------slot->suspend_time = ut_time()
------------slot->wait_timeout = wait_timeout
------------lock_wait_request_check_for_cycles
--------------lock_set_timeout_event
----------------os_event_set(lock_sys->timeout_event)//lock_wait_timeout_thread
----------thd_wait_begin
------------MYSQL_CALLBACK(thd->scheduler, thd_wait_begin, (thd, wait_type))
----------os_event_wait(slot->event);
----------thd_wait_end(trx->mysql_thd)
----------lock_wait_table_release_slot(slot);
----else
------parent = que_node_get_parent(thr);
------que_fork_start_command(parent)

```













