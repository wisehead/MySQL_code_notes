#1.Engine::HandleSelect

```
/*
Handles a single query
If an error appears during query preparation/optimization
query structures are cleaned up and the function returns information about the error through res'. If the query can not be compiled by Tianmu engine
QueryRouteTo::kToMySQL is returned and MySQL engine continues query
execution.
*/

Engine::HandleSelect
--optimize_select
```

#2.caller

```
ha_my_tianmu_query
```