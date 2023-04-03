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
--} else if (vcolumn::VirtualColumn::IsConstExpression(exprs[0], temp_table_alias, &temp_table->GetAliases()) &&
             exprs[0]->IsDeterministic()) {
--else
----vc = new vcolumn::ExpressionColumn(exprs[0], temp_table, temp_table_alias, mind);
--params = vc->GetParams();
--vc->SetParamTypes(&types);
--return vc;             
```