#1.TempTable::AddConds

```
TempTable::AddConds
--switch (type) {
----case CondType::WHERE_COND: {
      // need to add one by one since where_conds can be non-empty
------filter.AddConditions(cond, CondType::WHERE_COND);
      break;
```