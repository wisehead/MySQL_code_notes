#1.Optimize_table_order::find_best_ref

```cpp
Optimize_table_order::find_best_ref
--enum idx_type {CLUSTERED_PK, UNIQUE, NOT_UNIQUE, FULLTEXT};
--ha_rows distinct_keys_est= tab->records()/MATCHING_ROWS_IN_OTHER_TABLE;
--
```

#2.caller

```
JOIN::make_join_plan
--Optimize_table_order::choose_table_order
----Optimize_table_order::greedy_search
------Optimize_table_order::best_extension_by_limited_search
--------ptimize_table_order::best_access_path
----------find_best_ref
------

```