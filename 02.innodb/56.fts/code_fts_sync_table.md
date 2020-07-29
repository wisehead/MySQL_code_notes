#1.fts_sync_table

```cpp
caller:
--row_merge_read_clustered_index

fts_sync_table
--fts_sync
----fts_sync_index
------fts_sync_write_words
--------fts_write_node
----------pars_info_create
----------pars_info_bind_id（index_table_name）
------------pars_info_lookup_bound_id
----------pars_info_bind_varchar_literal（"token")
------------pars_info_add_literal
--------------ib_vector_push(info->bound_lits, pbl);
----------fts_bind_doc_id(info, "first_doc_id", &first_doc_id)
----------fts_bind_doc_id(info, "last_doc_id", &last_doc_id);
----------pars_info_bind_int4_literal(info, "doc_count",
----------pars_info_bind_literal(info, "ilist")
----------fts_parse_sql(fts_table, info,
                           "BEGIN\nINSERT INTO $index_table_name VALUES(:token, :first_doc_id,:last_doc_id, :doc_count, :ilist);")
----------fts_eval_sql
------------que_run_threads
```

#2.

```cpp
fts_eval_sql
--que_run_threads
----que_run_threads_low
------que_thr_step//QUE_NODE_THR
--------que_thr_node_step
------que_thr_step//QUE_NODE_PROC
--------proc_step
------que_thr_step//QUE_NODE_OPEN
--------open_step
----------sel_node_reset_cursor
------que_thr_step//QUE_NODE_WHILE
--------while_step
----------eval_exp
------------eval_func
------que_thr_step//QUE_NODE_FETCH
--------fetch_step
------que_thr_step//QUE_NODE_SELECT
--------row_sel_step
----------trx_start_if_not_started_xa
----------plan_reset_cursor
----------lock_table
----------row_sel

--------row_ins_step
----------row_ins
------------row_ins_index_entry_step
--------------row_ins_index_entry
----------------row_ins_clust_index_entry
------------------row_ins_clust_index_entry_low
--------------------btr_cur_optimistic_insert
----------------------page_cur_tuple_insert
------------------------page_cur_insert_rec_l
```