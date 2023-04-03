#1.TempTable::JoinT

```
TempTable::JoinT
--tables.push_back(t);
--aliases.push_back(alias);
--if (t->TableType() == TType::TEMP_TABLE) {
----//-
--else
----filter.mind_->AddDimension_cross(t->NumOfObj());
--join_types.push_back(jt);
--
```