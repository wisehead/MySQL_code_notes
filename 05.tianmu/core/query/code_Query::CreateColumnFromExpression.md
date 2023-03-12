#1.Query::CreateColumnFromExpression

```
Query::CreateColumnFromExpression
--Item *item = exprs[0]->GetItem();
--if (exprs[0]->IsDeterministic() && (exprs[0]->GetVars().empty())) {
----ColumnType type(exprs[0]->EvalType());
------switch (mysql_type) {
--------case INT_RESULT:  // prec = 0, scale = 0
----------type = DataType(common::ColumnType::BIGINT, 0, 0, DTCollation(), item->unsigned_flag);
----vc = new vcolumn::ConstColumn(*(exprs[0]->Evaluate()), type, true);
--params = vc->GetParams();
--
```