#1.row_create_index_for_mysql

```cpp
row_create_index_for_mysql
--dict_table_open_on_name
----dict_table_check_if_in_cache_low
--dict_move_to_mru
--trx_set_dict_operation
--ind_create_graph_create
----trx_commit_node_create
--pars_complete_graph_for_exec
----que_fork_create
----que_thr_create
--que_fork_start_command
--que_run_threads
----que_run_threads_low
------que_thr_step//QUE_NODE_THR == 9
--------que_thr_node_step
------que_thr_step//QUE_NODE_CREATE_INDEX == 15
--------dict_create_index_step
------que_thr_step//QUE_NODE_INSERT == 2
--------row_ins_step
------que_thr_step// QUE_NODE_CREATE_INDEX == 15
--------dict_create_index_step//node->state == INDEX_BUILD_FIELD_DEF
----------dict_build_field_def_step
------que_thr_step//QUE_NODE_INSERT == 2
--------row_ins_step
------que_thr_step// QUE_NODE_CREATE_INDEX == 15
--------dict_create_index_step//node->state == INDEX_BUILD_FIELD_DEF
----------node->state = INDEX_ADD_TO_CACHE;
----------dict_index_add_to_cache
----------node->state = INDEX_CREATE_INDEX_TREE
----------dict_create_index_tree_step
----------node->state = INDEX_COMMIT_WORK;
----------node->state = INDEX_CREATE_INDEX_TREE;
------que_thr_step//QUE_NODE_THR == 9
--------que_thr_node_step
----------thr->state = QUE_THR_COMPLETED;
--que_graph_free
--dict_table_close
```