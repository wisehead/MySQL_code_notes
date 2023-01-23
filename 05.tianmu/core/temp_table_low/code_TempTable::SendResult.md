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
```

#3.scan_fields

```
scan_fields
--
```