#1.JOIN::make_join_plan

```
JOIN::make_join_plan
--JOIN::init_planner_arrays
----for (JOIN_TAB *tab= join_tab;
       tl;
       tab++, tl= tl->next_leaf, best_ref_p++)
------table->init_cost_model(cost_model());
--trace_table_dependencies
--
```