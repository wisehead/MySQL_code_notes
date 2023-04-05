#1.Engine::InsertRow

```
Engine::InsertRow
--if (tianmu_sysvar_insert_delayed && table->s->tmp_table == NO_TMP_TABLE) {
----if (tianmu_sysvar_enable_rowstore) {
------InsertToDelta(table_path, share, table);
```