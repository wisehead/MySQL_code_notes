#1.Query::Item2CQTerm

```
Query::Item2CQTerm
--if (an_arg->type() == Item::SUBSELECT_ITEM) {
--if (filter_type == CondType::HAVING_COND) {
--else
----if (IsFieldItem(an_arg) && cq->ExistsInTempTable(tab, tmp_table)) {
------auto phys_vc = VirtualColumnAlreadyExists(tmp_table, tab, col);
------vc.n = phys_vc.second;
----} else if (an_arg->type() == Item::VARBIN_ITEM) {
----else
------WrapMysqlExpression
------vc.n = VirtualColumnAlreadyExists(tmp_table, expr);
------if (vc.n == common::NULL_VALUE_32) {
--------cq->CreateVirtualColumn(vc, tmp_table, expr);
--------tab_id2expression.insert(std::make_pair(tmp_table, std::make_pair(vc.n, expr)));
----term = CQTerm(vc.n, an_arg);
```