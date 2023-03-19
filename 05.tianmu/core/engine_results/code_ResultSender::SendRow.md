#2.ResultSender::SendRow
```
ResultSender::SendRow
--if (!is_initialized) 
----owner->CreateDisplayableAttrP()
------TempTable::CreateDisplayableAttrP
----Init(owner);
------ResultSender::Init
--------res->send_result_set_metadata(fields, Protocol::SEND_NUM_ROWS | Protocol::SEND_EOF);
----------Query_result_send::send_result_set_metadata
--------scan_fields(fields, buf_lens, items_backup);
--thd->current_found_rows++;
--thd->update_previous_found_rows();
--SendRecord(record);
----ResultSender::SendRecord
--rows_sent++;

```


#3.scan_fields

```
scan_fields
--while ((item = li++)) 
----item_type = item->type();
----buf_lens[item_id] = 0;
----switch (item_type) {
------case Item::FIELD_ITEM: {  // regular select
--------ifield = (Item_field *)item;
--------f = ifield->result_field;
--------auto iter_uf = used_fields.find((size_t)f);
--------if (iter_uf == used_fields.end()) {
          used_fields.insert((size_t)f);
          field_length = f->pack_length();
          buf_lens[item_id] = field_length;
          total_length += field_length;
----item_id++;
--while ((item = li++)) 
----item_type = item->type();
```

#4.ResultSender::SendRecord

```
ResultSender::SendRecord
--while ((item = li++)) {
----switch (item->type()) {
------case Item::FIELD_ITEM:  // regular select
--------ifield = (Item_field *)item;
--------f = ifield->result_field;
--------if (buf_lens[col_id] != 0) {
----------bitmap_set_bit(f->table->write_set, f->field_index);
----------auto is_null = Engine::ConvertToField(f, tianmu_dt, nullptr);
----------SetFieldState
------------if (is_null) {
------------else
--------------if (field->real_maybe_null())
----------------field->set_notnull();
```