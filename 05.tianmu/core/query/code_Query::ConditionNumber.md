#1.Query::ConditionNumber

```
Query::ConditionNumber
--Item::Type cond_type = conds->type();
--if (cond_type == Item::COND_ITEM) {
--} else if (cond_type == Item::FUNC_ITEM) {
----if (func_type == Item_func::NOT_FUNC && arg != nullptr && arg->type() == Item::SUBSELECT_ITEM &&
        ((Item_subselect *)arg)->substype() == Item_subselect::EXISTS_SUBS) {
----} else if (func_type == Item_func::XOR_FUNC) {
----else
------ConditionNumberFromComparison
```