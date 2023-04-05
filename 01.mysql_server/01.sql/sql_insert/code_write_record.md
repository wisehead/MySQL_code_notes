#1.write_record

```
write_record
--if (duplicate_handling == DUP_REPLACE || duplicate_handling == DUP_UPDATE)
----//-
--else if ((error=table->file->ha_write_row(table->record[0])))
----//-

```