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
caller:
prepare_inplace_alter_table_dict/ha_innobase::commit_inplace_alter_table
--row_merge_lock_table


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


#6.row_import_update_index_root

```cpp
caller:
- row_import_for_mysql
- row_discard_tablespace


row_import_update_index_root
--pars_sql
--graph->fork_type = QUE_FORK_MYSQL_INTERFACE
--que_fork_start_command
--que_run_threads
--que_graph_free
```


#7.row_merge_create_index_graph

```cpp
caller:
prepare_inplace_alter_table_dict
--row_merge_create_index


row_merge_create_index_graph
--ind_create_graph_create
----mem_heap_alloc(heap, sizeof(ind_node_t))
----node->common.type = QUE_NODE_CREATE_INDEX;
----node->index = index;
----node->add_v = add_v;
----node->ind_def = ins_node_create(INS_DIRECT,dict_sys->sys_indexes, heap);
----node->ind_def->common.parent = node;
----node->field_def = ins_node_create(INS_DIRECT,dict_sys->sys_fields, heap);
----node->field_def->common.parent = node;
--pars_complete_graph_for_exec
----fork = que_fork_create(NULL, NULL, QUE_FORK_MYSQL_INTERFACE, heap)
----thr = que_thr_create(fork, heap, prebuilt)
--que_fork_start_command
----que_thr_init_command
------thr->run_node = thr;
------thr->prev_node = thr->common.parent;
------que_thr_move_to_run_state
--que_run_threads
--que_graph_free((que_t*) que_node_get_parent(thr));

```

#8. row_create_table_for_mysql

```cpp
row_create_table_for_mysql
--node = tab_create_graph_create(table, heap)
----mem_heap_alloc(heap, sizeof(tab_node_t))
----node->common.type = QUE_NODE_CREATE_TABLE;
----node->table = table
----node->state = TABLE_BUILD_TABLE_DEF;
----node->tab_def = ins_node_create(INS_DIRECT, dict_sys->sys_tables,heap);
----node->tab_def->common.parent = node
----node->col_def = ins_node_create(INS_DIRECT, dict_sys->sys_columns,heap);
----node->col_def->common.parent = node;
----node->v_col_def = ins_node_create(INS_DIRECT, dict_sys->sys_virtual,heap);
----node->v_col_def->common.parent = node;
--pars_complete_graph_for_exec
----fork = que_fork_create(NULL, NULL, QUE_FORK_MYSQL_INTERFACE, heap);
----thr = que_thr_create(fork, heap, prebuilt);
--que_fork_start_command
--que_run_threads(thr)
--que_graph_free((que_t*) que_node_get_parent(thr));
```

#9. row_create_index_for_mysql

```cpp
row_create_index_for_mysql
--ind_create_graph_create
--pars_complete_graph_for_exec
----fork = que_fork_create(NULL, NULL, QUE_FORK_MYSQL_INTERFACE, heap)
----thr = que_thr_create(fork, heap, prebuilt);
--que_fork_start_command
--que_run_threads(thr);
--que_graph_free((que_t*) que_node_get_parent(thr));
```

#10. row_mysql_lock_table

```cpp
caller:
- ha_innobase::discard_or_import_tablespace


row_mysql_lock_table
--node = sel_node_create(heap)
----mem_heap_alloc(heap, sizeof(sel_node_t))
----node->common.type = QUE_NODE_SELECT;
----node->state = SEL_NODE_OPEN;
--pars_complete_graph_for_exec
----que_fork_create
----que_thr_create
--thr->graph->state = QUE_FORK_ACTIVE;
--que_fork_get_first_thr
--que_thr_move_to_run_state_for_mysql
----thr->is_active = TRUE;
----thr->state = QUE_THR_RUNNING;
--run_again：
--thr->run_node = thr;
--thr->prev_node = thr->common.parent;
--lock_table(0, table, mode, thr);
----lock_table_enqueue_waiting
------que_thr_stop
--------thr->state = QUE_THR_LOCK_WAIT;
--if (err == DB_SUCCESS)
----que_thr_stop_for_mysql_no_error
------thr->state = QUE_THR_COMPLETED;
--else
----que_thr_stop_for_mysql
----if (err != DB_QUE_THR_SUSPENDED)
------case DB_LOCK_WAIT:
------trx_kill_blocking
------lock_wait_suspend_thread
--------lock_wait_table_reserve_slot
--------thd_wait_begin
--------os_event_wait(slot->event);
--------thd_wait_end
--------lock_wait_table_release_slot
--------goto run_again;
----else
------parent = que_node_get_parent(thr);
------que_fork_start_command
------trx->error_state = DB_LOCK_WAIT;
------goto run_again;
--que_graph_free(thr->graph);
```

#11. trx_rollback_to_savepoint_low

```cpp
caller:
- trx_rollback_to_savepoint
- trx_rollback_for_mysql_low


trx_rollback_to_savepoint_low
--roll_node_create
----node = static_cast<roll_node_t*>(mem_heap_zalloc(heap, sizeof(*node)))
----node->state = ROLL_NODE_SEND;
----node->common.type = QUE_NODE_ROLLBACK;
--if (savept != NULL)
----roll_node->partial = TRUE
----roll_node->savept = *savept;
----check_trx_state(trx)
--else
----assert_trx_nonlocking_or_in_list
--if (trx_is_rseg_updated(trx))
----thr = pars_complete_graph_for_exec(roll_node, trx, heap, NULL);
------fork = que_fork_create(NULL, NULL, QUE_FORK_MYSQL_INTERFACE, heap);
------que_thr_create
--------thr->state = QUE_THR_COMMAND_WAIT;
----que_fork_start_command
------case QUE_THR_COMMAND_WAIT:
------que_thr_init_command
--------que_thr_move_to_run_state
----que_run_threads(thr);//运行过程中，会设置roll_node->undo_thr
----que_run_threads(roll_node->undo_thr);
----que_graph_free(static_cast<que_t*>(roll_node->undo_thr->common.parent));
--if (savept == NULL)
----trx_rollback_finish
--else
----trx->lock.que_state = TRX_QUE_RUNNING;
```

#12. trx_rollback_active

```cpp
caller:
trx_rollback_or_clean_recovered
--trx_rollback_resurrected

trx_rollback_active
--fork = que_fork_create(NULL, NULL, QUE_FORK_RECOVERY, heap);
--que_thr_create
--roll_node = roll_node_create(heap);
--que_fork_start_command
--que_run_threads(thr);
--que_run_threads(roll_node->undo_thr);
--trx_rollback_finish(thr_get_trx(roll_node->undo_thr))
--que_graph_free
```

#13. trx_rollback_start

```cpp
caller：
que_thr_step
--trx_rollback_step


trx_rollback_start
--que_t*  roll_graph = trx_roll_graph_build(trx);
----fork = que_fork_create(NULL, NULL, QUE_FORK_ROLLBACK, heap)
----que_thr_create
----row_undo_node_create(trx, thr, heap)
------mem_heap_alloc(heap, sizeof(undo_node_t))
------undo->common.type = QUE_NODE_UNDO
------undo->common.parent = parent
------undo->state = UNDO_NODE_FETCH_NEXT
------btr_pcur_init(&(undo->pcur))
--trx->graph = roll_graph;
--trx->lock.que_state = TRX_QUE_ROLLING_BACK;
--que_fork_start_command(roll_graph)
```

#99.todo debug


























