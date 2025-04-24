1.stack

```cpp
#0  Sql_cmd_insert::execute (this=0x555558eb9870, thd=0x555558ea2f80) at /home/chenhui/github/mysql-server-5.7/sql/sql_insert.cc:3117
#1  0x0000555556b6bccc in mysql_execute_command (thd=0x555558ea2f80, first_level=true) at /home/chenhui/github/mysql-server-5.7/sql/sql_parse.cc:3607
#2  0x0000555556b71cae in mysql_parse (thd=0x555558ea2f80, parser_state=0x7fffd8160490) at /home/chenhui/github/mysql-server-5.7/sql/sql_parse.cc:5584
#3  0x0000555556b66863 in dispatch_command (thd=0x555558ea2f80, com_data=0x7fffd8160d40, command=COM_QUERY) at /home/chenhui/github/mysql-server-5.7/sql/sql_parse.cc:1492
#4  0x0000555556b65675 in do_command (thd=0x555558ea2f80) at /home/chenhui/github/mysql-server-5.7/sql/sql_parse.cc:1031
#5  0x0000555556cb5191 in handle_connection (arg=0x5555590abd60) at /home/chenhui/github/mysql-server-5.7/sql/conn_handler/connection_handler_per_thread.cc:313
#6  0x0000555557433fc7 in pfs_spawn_thread (arg=0x555558e96af0) at /home/chenhui/github/mysql-server-5.7/storage/perfschema/pfs.cc:2197
#7  0x00007ffff75c3ac3 in start_thread (arg=<optimized out>) at ./nptl/pthread_create.c:442
#8  0x00007ffff7655850 in clone3 () at ../sysdeps/unix/sysv/linux/x86_64/clone3.S:81
```

2.code flow

```cpp
mysql_execute_command
--Sql_cmd_insert::execute
----open_temporary_tables
----Sql_cmd_insert_base::insert_precheck
----Sql_cmd_insert::mysql_insert
------open_tables_for_query
------Sql_cmd_insert_base::mysql_prepare_insert
------context= &select_lex->context;
------ctx_state.save_state(context, table_list);
------context->resolve_in_table_list_only(table_list);
------ctx_state.restore_state(context, table_list);
------lock_tables
------prepare_triggers_for_insert_stmt
------while ((values= its++))
--------write_record
----------handler::ha_write_row
------------ha_innobase::write_row
--------------innobase_srv_conc_enter_innodb(m_prebuilt);
--------------row_insert_for_mysql
----------------row_insert_for_mysql_using_ins_graph
------------------row_get_prebuilt_insert_row
------------------row_mysql_convert_row_to_innobase
------------------que_fork_get_first_thr
------------------que_thr_move_to_run_state_for_mysql
------------------row_ins_step
--------------------lock_table
--------------------row_ins
----------------------row_ins_index_entry_step
------------------------row_ins_index_entry_set_vals
------------------------row_ins_index_entry
--------------------------row_ins_clust_index_entry
----------------------------row_ins_clust_index_entry_low
------------------------------mtr_start(&mtr);
------------------------------btr_pcur_open_low
--------------------------------btr_cur_search_to_nth_level
----------------------------------btr_cur_latch_for_root_leaf
----------------------------------btr_cur_get_page_cur
--------------------------------btr_cur_optimistic_insert
----------------------------------page_cur_get_rec
----------------------------------btr_cur_ins_lock_and_undo
----------------------------------page_cur_tuple_insert
------------------------------------rec_convert_dtuple_to_rec
------------------------------------page_cur_insert_rec_low
--------------------------------------page_cur_insert_rec_write_log
----------------------------------------mlog_open_and_write_index
----------------------------------btr_search_update_hash_on_insert
------------------------------mtr_commit(&mtr);
------------------------------btr_pcur_close(&pcur);
--------------------thr->run_node = que_node_get_parent(node);
--------------innobase_srv_conc_exit_innodb(m_prebuilt);
------------binlog_log_row
------thd->get_stmt_da()->inc_current_row_for_condition();
------query_cache.invalidate_single(thd, lex->insert_table_leaf, true);
--thd->query_plan.set_query_plan(SQLCOM_END, NULL, false);
--mysql_audit_notify
--trans_commit_stmt(thd);
--lex->unit->cleanup(true);
--close_thread_tables(thd);
--stmt_causes_implicit_commit
--thd->mdl_context.release_transactional_locks();
--binlog_gtid_end_transaction(thd);  // finalize GTID life-cycle
```