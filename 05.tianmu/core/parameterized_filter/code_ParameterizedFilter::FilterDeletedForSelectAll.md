#1.ParameterizedFilter::FilterDeletedForSelectAll

```
ParameterizedFilter::FilterDeletedForSelectAll
--&rcTables = table_->GetTables();
--for (uint tableIndex = 0; tableIndex < rcTables.size(); tableIndex++) {
----auto rcTable = rcTables[tableIndex];
----if (rcTable->TableType() == TType::TEMP_TABLE)
------continue;
----FilterDeletedByTable(rcTable, no_dims, tableIndex);
---no_dims++;
--mind_->UpdateNumOfTuples();
```