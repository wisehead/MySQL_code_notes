#1.TABLE_LIST::setup_materialized_derived

```
TABLE_LIST::setup_materialized_derived
--set_uses_materialization
----effective_algorithm= VIEW_ALGORITHM_TEMPTABLE;
--const ulonglong create_options= derived->first_select()->active_options() |
                                  TMP_TABLE_ALL_COLUMNS;
--(derived_result->create_result_table(thd, &derived->types, false, 
                                          create_options,
                                          alias, false, false))
```