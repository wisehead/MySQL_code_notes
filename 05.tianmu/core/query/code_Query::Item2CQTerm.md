#1.Query::Item2CQTerm

```
Query::Item2CQTerm
--if (an_arg->type() == Item::SUBSELECT_ITEM) {
--if (filter_type == CondType::HAVING_COND) {
--else
----if (IsFieldItem(an_arg) && cq->ExistsInTempTable(tab, tmp_table)) {
----} else if (an_arg->type() == Item::VARBIN_ITEM) {
----else
------WrapMysqlExpression
```