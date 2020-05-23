#1.mysql_execute_command
#1.1 overall

```cpp
int mysql_execute_command(THD *thd) {
    LEX  *lex= thd->lex;  // 解析过后的SQL语句的语法结构
    TABLE_LIST *all_tables = lex->query_tables;   // 该语句要访问的表的列表
    switch (lex->sql_command) {
        ...
        case SQLCOM_INSERT:
            insert_precheck(thd, all_tables);
            mysql_insert(thd, all_tables, lex->field_list, lex->many_values, lex->update_list, lex->value_list, lex->duplicates, lex->ignore);
            break; ...
        case SQLCOM_SELECT:
            check_table_access(thd, lex->exchange ? SELECT_ACL | FILE_ACL :  SELECT_ACL,  all_tables, UINT_MAX, FALSE);    // 检查用户对数据表的访问权限
            execute_sqlcom_select(thd, all_tables);     // 执行select语句
            break;
    }
}
```
#1.2 stack

```cpp
(gdb) bt
#0  mysql_execute_command (thd=thd@entry=0x16a3f80) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:2380
#1  0x00000000006f66d8 in mysql_parse (thd=thd@entry=0x16a3f80, rawbuf=<optimized out>, length=<optimized out>, parser_state=parser_state@entry=0x7fffa4588770) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:6549
#2  0x00000000006f7c32 in dispatch_command (command=COM_QUERY, thd=0x16a3f80, packet=<optimized out>, packet_length=<optimized out>) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:1339
#3  0x00000000006f99d6 in do_command (thd=<optimized out>) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:1037
#4  0x00000000006c0d2d in do_handle_one_connection (thd_arg=thd_arg@entry=0x16a3f80) at /home/chenhui/mysql-5623-trunk/sql/sql_connect.cc:982
#5  0x00000000006c0d78 in handle_one_connection (arg=arg@entry=0x16a3f80) at /home/chenhui/mysql-5623-trunk/sql/sql_connect.cc:898
#6  0x0000000000b48443 in pfs_spawn_thread (arg=0x16eafc0) at /home/chenhui/mysql-5623-trunk/storage/perfschema/pfs.cc:1860
#7  0x00007ffff7bc61c3 in start_thread () from /opt/compiler/gcc-4.8.2/lib/libpthread.so.0
#8  0x00007ffff6ca112d in clone () from /opt/compiler/gcc-4.8.2/lib/libc.so.6
```

#1.3 detail

```cpp
mysql_execute_command
--LEX::first_lists_tables_same
--resolve_in_table_list_only
--deny_updates_if_read_only_option
--open_temporary_tables
--switch (lex->sql_command)
--case SQLCOM_SELECT:
--select_precheck
----check_table_access
--execute_sqlcom_select
--trans_commit_stmt
--close_thread_tables
----ha_innobase::extra
----mark_temp_tables_as_free_for_reuse
----binlog_flush_pending_rows_event
------THD::binlog_flush_pending_rows_event
--------THD::binlog_get_pending_rows_event
```