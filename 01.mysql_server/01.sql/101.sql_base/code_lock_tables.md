#1.lock_tables

```
lock_tables
--if (! thd->locked_tables_mode)
----(!(ptr=start=(TABLE**) thd->alloc(sizeof(TABLE*)*count)))
----for (table= tables; table; table= table->next_global)
------if (!table->is_placeholder() &&!(table->prelocking_placeholder &&
            table->table->s->tmp_table != NO_TMP_TABLE))
-------- *(ptr++)= table->table;
----(thd->lock= mysql_lock_tables(thd, start, (uint) (ptr - start),flags)))
```