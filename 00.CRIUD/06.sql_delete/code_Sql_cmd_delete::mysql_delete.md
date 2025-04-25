#1.Sql_cmd_delete::mysql_delete

```
Sql_cmd_delete::mysql_delete
--open_tables_for_query
--run_before_dml_hook
--mysql_prepare_delete
--select_lex->get_optimizable_conditions(thd, &conds, NULL)
--substitute_gc
--lock_tables
--if (conds)
----optimize_cond
----conds= substitute_for_best_equal_field(conds, cond_equal, 0);
----conds->update_used_tables();
--table->init_cost_model(thd->cost_model());
--test_quick_select
--if (usable_index==MAX_KEY || qep_tab.quick())
----error= init_read_record(&info, thd, NULL, &qep_tab, 1, 1, FALSE);
--
```