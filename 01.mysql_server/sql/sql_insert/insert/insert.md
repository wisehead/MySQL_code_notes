#1.mysql_insert

```cpp
mysql_insert
--mysql_prepare_insert
```

#2.stack

```
(gdb) bt
#0  btr_cur_search_to_nth_level (index=index@entry=0x7fd7f412c2f8, level=level@entry=0, tuple=tuple@entry=0x7fd7f432f218, mode=mode@entry=4, latch_mode=latch_mode@entry=2, cursor=cursor@entry=0x7fd814112a70, has_search_latch=0,
    file=0xcbf190 "/home/chenhui/mysql-5623-trunk/storage/innobase/row/row0ins.cc", line=2338, mtr=0x7fd814112e10) at /home/chenhui/mysql-5623-trunk/storage/innobase/btr/btr0cur.cc:404
#1  0x0000000000997719 in row_ins_clust_index_entry_low (flags=<optimized out>, mode=2, index=0x7fd7f412c2f8, n_uniq=0, entry=0x7fd7f432f218, n_ext=<optimized out>, thr=<optimized out>) at /home/chenhui/mysql-5623-trunk/storage/innobase/row/row0ins.cc:2337
#2  0x00000000009986b1 in row_ins_clust_index_entry (index=index@entry=0x7fd7f412c2f8, entry=entry@entry=0x7fd7f432f218, thr=thr@entry=0x7fd7f41332e0, n_ext=n_ext@entry=0) at /home/chenhui/mysql-5623-trunk/storage/innobase/row/row0ins.cc:2866
#3  0x0000000000998bdd in row_ins_index_entry (thr=0x7fd7f41332e0, entry=<optimized out>, index=<optimized out>) at /home/chenhui/mysql-5623-trunk/storage/innobase/row/row0ins.cc:2965
#4  row_ins_index_entry_step (thr=<optimized out>, node=0x7fd7f4132f80) at /home/chenhui/mysql-5623-trunk/storage/innobase/row/row0ins.cc:3042
#5  row_ins (thr=0x7fd7f412c2f8, node=0x7fd7f4132f80) at /home/chenhui/mysql-5623-trunk/storage/innobase/row/row0ins.cc:3182
#6  row_ins_step (thr=thr@entry=0x7fd7f41332e0) at /home/chenhui/mysql-5623-trunk/storage/innobase/row/row0ins.cc:3307
#7  0x00000000009a1d3b in row_insert_for_mysql (mysql_rec=mysql_rec@entry=0x7fd7f4135420 "\374\002", prebuilt=0x7fd7f4132aa8) at /home/chenhui/mysql-5623-trunk/storage/innobase/row/row0mysql.cc:1367
#8  0x000000000092bed0 in ha_innobase::write_row (this=0x7fd7f41299b0, record=0x7fd7f4135420 "\374\002") at /home/chenhui/mysql-5623-trunk/storage/innobase/handler/ha_innodb.cc:6645
#9  0x00000000005e39ab in handler::ha_write_row (this=0x7fd7f41299b0, buf=0x7fd7f4135420 "\374\002") at /home/chenhui/mysql-5623-trunk/sql/handler.cc:7273
#10 0x00000000006e6ae5 in write_record (thd=thd@entry=0x5fe3a80, table=table@entry=0x7fd7f41290c0, info=info@entry=0x7fd8141136b0, update=update@entry=0x7fd814113730) at /home/chenhui/mysql-5623-trunk/sql/sql_insert.cc:1921
#11 0x00000000006edb57 in mysql_insert (thd=thd@entry=0x5fe3a80, table_list=0x7fd7f4005038, fields=..., values_list=..., update_fields=..., update_values=..., duplic=DUP_ERROR, ignore=false) at /home/chenhui/mysql-5623-trunk/sql/sql_insert.cc:1072
#12 0x00000000006ffede in mysql_execute_command (thd=0x5fe3a80) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:3457
#13 0x00000000007040db in mysql_parse (thd=thd@entry=0x5fe3a80, rawbuf=<optimized out>, length=<optimized out>, parser_state=parser_state@entry=0x7fd814114760) at /home/chenhui/mysql-5623-trunk/sql/sql_parse.cc:6373
#14 0x0000000000706188 in dispatch_command (command=COM_QUERY, thd=0x5fe3a80, packet=0x60bf301 "insert t1 values(2, 'peter')", packet_length=<optimized out>) at /home/chenhui/mysql-5623-trunk/sql/sql_class.h:851
#15 0x00000000006d2256 in do_handle_one_connection (thd_arg=thd_arg@entry=0x5fe3a80) at /home/chenhui/mysql-5623-trunk/sql/sql_connect.cc:982
#16 0x00000000006d2358 in handle_one_connection (arg=arg@entry=0x5fe3a80) at /home/chenhui/mysql-5623-trunk/sql/sql_connect.cc:898
#17 0x0000000000b00ec6 in pfs_spawn_thread (arg=0x60388e0) at /home/chenhui/mysql-5623-trunk/storage/perfschema/pfs.cc:1860
#18 0x00007fd8eb313da4 in start_thread (arg=<optimized out>) at pthread_create.c:333
#19 0x00007fd8eaf6632d in clone () at ../sysdeps/unix/sysv/linux/x86_64/clone.S:109
```



