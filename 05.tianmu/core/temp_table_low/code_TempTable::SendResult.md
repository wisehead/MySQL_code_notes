#1.TempTable::SendResult

```
TempTable::SendResult
--while (it.IsValid() && row < no_obj) 
----std::vector<std::unique_ptr<types::TianmuDataType>> record;
----for (uint att = 0; att < NumOfDisplaybleAttrs(); ++att) {
------Attr *col = GetDisplayableAttrP(att);
------common::ColumnType ct = col->TypeName();
------if (ct == common::ColumnType::INT || ct == common::ColumnType::MEDIUMINT || ct == common::ColumnType::SMALLINT ||
          ct == common::ColumnType::BYTEINT || ct == common::ColumnType::NUM || ct == common::ColumnType::BIGINT ||
          ct == common::ColumnType::BIT) {
--------data_ptr->Assign(vc->GetValueInt64(it), col->Type().GetScale(), false, ct);
--------record.emplace_back(data_ptr);
------} else if (ATI::IsRealType(ct)) {
------} else if (ATI::IsDateTimeType(ct)) {
------else
--------vc->GetNotNullValueString(*data_ptr, it);//SingleColumn
----------col_->GetNotNullValueString(mit[dim_], s);
------------TempTable::GetNotNullValueString
--------------TempTable::Attr::GetValueString
--ResultSender::SendRow
```

#2.ResultSender::SendRow
```
ResultSender::SendRow
--if (!is_initialized) 
----owner->CreateDisplayableAttrP()
------TempTable::CreateDisplayableAttrP
----Init(owner);
------ResultSender::Init
--------res->send_result_set_metadata(fields, Protocol::SEND_NUM_ROWS | Protocol::SEND_EOF);
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




