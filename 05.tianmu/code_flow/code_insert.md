#1.Sql_cmd_insert::mysql_insert

```
Sql_cmd_insert::mysql_insert
--open_tables_for_query
--run_before_dml_hook
--mysql_prepare_insert
--context->resolve_in_table_list_only(table_list);
--lock_tables
--write_record
----handler::ha_write_row
------ha_tianmu::write_row
--------Engine::InsertRow
----------EncodeRecord(table_path, share->TabID(), table->field, table->s->fields, table->s->blob_fields, buf, buf_sz,
               table->in_use);
----------rctable = share->GetSnapshot();
------------return current = std::make_shared<TianmuTable>(table_path, this);
----------rctable->InsertMemRow(std::move(buf), buf_sz);
------------TianmuTable::InsertMemRow
```