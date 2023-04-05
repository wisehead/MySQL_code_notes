#1.Engine::InsertToDelta

```
Engine::InsertToDelta
--auto tm_table = share->GetSnapshot();
--row_id = tm_table->NextRowId();
----TianmuTable::NextRowId() { 
------return m_delta->row_id++; }
--// Insert primary key first
--tm_table->InsertIndexForDelta(table, row_id);
```