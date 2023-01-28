#1. mysql_lock_tables(innodb)

```cpp
caller:
--lock_tables

mysql_lock_tables
--lock_tables_check
--get_lock_data//把file->lock返回，file是innodb_handler.
----ha_innobase::store_lock
------check_trx_exists
--------thd_to_trx
----------thd_ha_data
--------innobase_trx_init
------thd_tx_isolation
------thd_in_lock_tables
------thd_sql_command、
--lock_external
----handler::ha_external_lock
------ha_innobase::external_lock
--------ha_innobase::external_lock//todo ........？？？？？？？？
--thr_multi_lock
```

#2.ha_innobase::external_lock//todo

#3.mysql_lock_tables(tianmu)
```
mysql_lock_tables
--lock_tables_check
----for (i=0 ; i<count; i++)
------if (!(flags & MYSQL_LOCK_IGNORE_GLOBAL_READ_ONLY) && !t->s->tmp_table &&
        !is_perfschema_db(t->s->db.str, t->s->db.length))
--------if (t->reginfo.lock_type >= TL_WRITE_ALLOW_WRITE &&
        check_readonly(thd, true))
--(! (sql_lock= get_lock_data(thd, tables, count, GET_LOCK_STORE_LOCKS)))
--(sql_lock->table_count && lock_external(thd, sql_lock->table,
                                             sql_lock->table_count))

```

#4.get_lock_data

```
get_lock_data
--for (i=tables=lock_count=0 ; i < count ; i++)
----TABLE *t= table_ptr[i];
----if (t->s->tmp_table != NON_TRANSACTIONAL_TMP_TABLE)
------tables+= t->file->lock_count();
------lock_count++;
--(!(sql_lock= (MYSQL_LOCK*)
	my_malloc(key_memory_MYSQL_LOCK,
                  sizeof(*sql_lock) +
		  sizeof(THR_LOCK_DATA*) * tables * 2 +
                  sizeof(table_ptr) * lock_count,
		  MYF(0))))
--locks= locks_buf= sql_lock->locks= (THR_LOCK_DATA**) (sql_lock + 1);
--to= table_buf= sql_lock->table= (TABLE**) (locks + tables * 2);
--sql_lock->table_count=lock_count;
--for (i=0 ; i < count ; i++)
----locks_start= locks;
    locks= table->file->store_lock(thd, locks,
                                   (flags & GET_LOCK_UNLOCK) ? TL_IGNORE :
                                   lock_type);
----if (flags & GET_LOCK_STORE_LOCKS)
------table->lock_position=   (uint) (to - table_buf);
------table->lock_data_start= (uint) (locks_start - locks_buf);
------table->lock_count=      (uint) (locks - locks_start);
----*to++= table;
--sql_lock->lock_count= locks - locks_buf;
```






