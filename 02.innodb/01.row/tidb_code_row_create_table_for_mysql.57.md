#1.row_create_table_for_mysql

```cpp

caller:
-create_table_info_t::create_table_def


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

#2.stack for create table

```cpp
(gdb) bt
#0  row_create_table_for_mysql (table=0x7ff20c9f5420, compression=0x0, trx=0x7ff49e000ff8, commit=false)
    at /home/chenhui/txsql-ncdb/storage/innobase/row/row0mysql.cc:3011
#1  0x0000000001a74bb0 in create_table_info_t::create_table_def (this=0x7ff4681f7a40)
    at /home/chenhui/txsql-ncdb/storage/innobase/handler/ha_innodb.cc:11056
#2  0x0000000001a60d84 in create_table_info_t::create_table (this=0x7ff4681f7a40)
    at /home/chenhui/txsql-ncdb/storage/innobase/handler/ha_innodb.cc:12587
#3  0x0000000001a61957 in ha_innobase::create (this=0x7ff464776c30, name=0x7ff4681fa5d0 "./hi/t1", form=0x7ff4681f8830, create_info=0x7ff4681fb0b0)
    at /home/chenhui/txsql-ncdb/storage/innobase/handler/ha_innodb.cc:12935
#4  0x0000000000fecd5c in handler::ha_create (this=0x7ff464776c30, name=0x7ff4681fa5d0 "./hi/t1", form=0x7ff4681f8830, info=0x7ff4681fb0b0)
    at /home/chenhui/txsql-ncdb/sql/handler.cc:4987
#5  0x0000000000fed35a in ha_create_table (thd=0x7ff21b1db000, path=0x7ff4681fa5d0 "./hi/t1", db=0x7ff21b0a9748 "hi", table_name=0x7ff21b0a9188 "t1",
    create_info=0x7ff4681fb0b0, update_create_info=false, is_temp_table=false) at /home/chenhui/txsql-ncdb/sql/handler.cc:5146
#6  0x00000000016e654b in rea_create_table (thd=0x7ff21b1db000, path=0x7ff4681fa5d0 "./hi/t1", db=0x7ff21b0a9748 "hi", table_name=0x7ff21b0a9188 "t1",
    create_info=0x7ff4681fb0b0, create_fields=..., keys=0, key_info=0x7ff21b0a9dc0, file=0x7ff21b0a9ad0, no_ha_table=false)
    at /home/chenhui/txsql-ncdb/sql/unireg.cc:1027
#7  0x0000000001654266 in create_table_impl (thd=0x7ff21b1db000, db=0x7ff21b0a9748 "hi", table_name=0x7ff21b0a9188 "t1",
    error_table_name=0x7ff21b0a9188 "t1", path=0x7ff4681fa5d0 "./hi/t1", create_info=0x7ff4681fb0b0, alter_info=0x7ff4681fab20,
    internal_tmp_table=false, select_field_count=0, no_ha_table=false, is_trans=0x7ff4681fa9ff, key_info=0x7ff4681fa7e0, key_count=0x7ff4681fa7dc)
    at /home/chenhui/txsql-ncdb/sql/sql_table.cc:5424
#8  0x0000000001654810 in mysql_create_table_no_lock (thd=0x7ff21b1db000, db=0x7ff21b0a9748 "hi", table_name=0x7ff21b0a9188 "t1",
    create_info=0x7ff4681fb0b0, alter_info=0x7ff4681fab20, select_field_count=0, is_trans=0x7ff4681fa9ff)
    at /home/chenhui/txsql-ncdb/sql/sql_table.cc:5556
#9  0x0000000001654976 in mysql_create_table (thd=0x7ff21b1db000, create_table=0x7ff21b0a91c0, create_info=0x7ff4681fb0b0, alter_info=0x7ff4681fab20)
    at /home/chenhui/txsql-ncdb/sql/sql_table.cc:5607
#10 0x00000000015c4395 in mysql_execute_command (thd=0x7ff21b1db000, first_level=true) at /home/chenhui/txsql-ncdb/sql/sql_parse.cc:3973
#11 0x00000000015cb41d in mysql_parse (thd=0x7ff21b1db000, parser_state=0x7ff4681fbc40) at /home/chenhui/txsql-ncdb/sql/sql_parse.cc:6528
#12 0x00000000015bec5f in dispatch_command (thd=0x7ff21b1db000, com_data=0x7ff4681fc430, command=COM_QUERY)
    at /home/chenhui/txsql-ncdb/sql/sql_parse.cc:1676
#13 0x00000000015bd42d in do_command (thd=0x7ff21b1db000) at /home/chenhui/txsql-ncdb/sql/sql_parse.cc:1078
#14 0x00000000016d1479 in threadpool_process_request (thd=0x7ff21b1db000) at /home/chenhui/txsql-ncdb/sql/threadpool_common.cc:275
#15 0x00000000016d4730 in handle_event (connection=0x7ff4a3248ae0) at /home/chenhui/txsql-ncdb/sql/threadpool_unix.cc:1605
#16 0x00000000016d4980 in worker_main (param=0x2f4c200 <all_groups+2048>) at /home/chenhui/txsql-ncdb/sql/threadpool_unix.cc:1677
#17 0x00000000019b78f1 in pfs_spawn_thread (arg=0x7ff21b36b320) at /home/chenhui/txsql-ncdb/storage/perfschema/pfs.cc:2188
#18 0x00007ff4a4cbcea5 in start_thread () from /lib64/libpthread.so.0
#19 0x00007ff4a398096d in clone () from /lib64/libc.so.6
```