#1.OperationUnmysterify

```
OperationUnmysterify
--switch (static_cast<int>(item->type())) {
----case Item::FIELD_ITEM:                  // regular select
------oper = common::ColOperation::LISTING; /*GROUP_BY : LISTING;*/
----case Item::SUM_FUNC_ITEM:  // min(k), max(k), count(), avg(k), sum
------case Item_sum::COUNT_DISTINCT_FUNC:
          distinct = true;
          [[fallthrough]];
------case Item_sum::COUNT_FUNC:
          oper = common::ColOperation::COUNT; /*common::ColOperation::COUNT;*/
          break;
```