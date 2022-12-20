#1.mysql_execute_select

```
mysql_execute_select
--JOIN* join= select_lex->join;
--if (optimize_after_sdb)
----err= join->optimize(part);
--else
----err= join->optimize();
--join->exec();
```

#2.caller

```
mysql_select
--mysql_execute_select
```

#3.caller of mysql_select

```
- mysql_multi_update
- mysql_explain_unit
- mysql_execute_command
- handle_select
- st_select_lex_unit::explain()
- st_select_lex_unit::exec()
```
