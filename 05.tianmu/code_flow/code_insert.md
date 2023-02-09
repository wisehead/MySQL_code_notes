#1.Sql_cmd_insert::mysql_insert

```
Sql_cmd_insert::mysql_insert
--write_record
----handler::ha_write_row
------ha_tianmu::write_row
--------Engine::InsertRow
----------EncodeRecord(table_path, share->TabID(), table->field, table->s->fields, table->s->blob_fields, buf, buf_sz,
               table->in_use);
----------rctable = share->GetSnapshot();
----------rctable->InsertMemRow(std::move(buf), buf_sz);
```