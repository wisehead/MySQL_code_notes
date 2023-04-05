#1.Sql_cmd_insert::mysql_insert

```
Sql_cmd_insert::mysql_insert
--open_tables_for_query
--mysql_prepare_insert
--// Lock the tables now if not locked already.
--if (!is_locked &&
      lock_tables(thd, table_list, lex->table_count, 0))
    DBUG_RETURN(true);
--while ((values= its++))
----write_record(thd, insert_table, &info, &update);
```