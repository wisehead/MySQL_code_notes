#1.Engine::InsertToDelta

```
Engine::InsertToDelta
--auto tm_table = share->GetSnapshot();
--row_id = tm_table->NextRowId();
----TianmuTable::NextRowId() { 
------return m_delta->row_id++; }
--// Insert primary key first
--tm_table->InsertIndexForDelta(table, row_id);
--EncodeInsertRecord(table_path, table->field, table->s->fields, table->s->blob_fields, buf, buf_sz, table->in_use);
--tm_table->InsertToDelta(row_id, std::move(buf), buf_sz);
```