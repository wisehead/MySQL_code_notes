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
--------------row_insert_for_mysql
----------------row_insert_for_mysql_using_ins_graph
```