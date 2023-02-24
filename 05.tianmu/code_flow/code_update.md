#1.update code flow

```
mysql_update
--mysql_prepare_update
--select_lex->get_optimizable_conditions(thd, &conds, NULL)
--lock_tables
--optimize_cond
--init_read_record
```