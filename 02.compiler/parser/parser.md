#1.stack of “select * from tt”

```cpp
(gdb) bt
#0  lex_one_token (yylval=0x7f9190414130, thd=0x7f918e29b800) at /home/chenhui/mysql-5623-trunk/sql/sql_lex.cc:972
#1  0x00000000006e2cf2 in MYSQLlex (yylval=yylval@entry=0x7f9190414130, thd=thd@entry=0x7f918e29b800) at /home/chenhui/mysql-5623-trunk/sql/sql_lex.cc:931
#2  0x0000000000791ac0 in MYSQLparse (YYTHD=YYTHD@entry=0x7f918e29b800) at /home/chenhui/mysql-5623-trunk/release/sql/sql_yacc.cc:17536
#3  0x00000000006f6447 in parse_sql (creation_ctx=0x0, parser_state=0x7f9190414f30, thd=0x7f918e29b800) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:8535
#4  mysql_parse (thd=thd@entry=0x7f918e29b800, rawbuf=<optimized out>, length=16, parser_state=parser_state@entry=0x7f9190414f30) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:6453
#5  0x00000000006f7c32 in dispatch_command (command=COM_QUERY, thd=0x7f918e29b800, packet=<optimized out>, packet_length=<optimized out>) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:1339
#6  0x00000000006f99d6 in do_command (thd=<optimized out>) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:1037
#7  0x00000000006c0d2d in do_handle_one_connection (thd_arg=thd_arg@entry=0x7f918e29b800) at /home/chenhui/mysql-5623-trunk/sql/sql_connect.cc:982
#8  0x00000000006c0d78 in handle_one_connection (arg=arg@entry=0x7f918e29b800) at /home/chenhui/mysql-5623-trunk/sql/sql_connect.cc:898
#9  0x0000000000b48443 in pfs_spawn_thread (arg=0x7f9174278f40) at /home/chenhui/mysql-5623-trunk/storage/perfschema/pfs.cc:1860
#10 0x00007f918f97d1c3 in start_thread () from /opt/compiler/gcc-4.8.2/lib/libpthread.so.0
#11 0x00007f918ea5812d in clone () from /opt/compiler/gcc-4.8.2/lib/libc.so.6

```

#2.