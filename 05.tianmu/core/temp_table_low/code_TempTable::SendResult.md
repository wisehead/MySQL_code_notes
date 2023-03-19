#1.TempTable::SendResult

```
TempTable::SendResult
--for (auto &attr : attrs) { /* materialize dependent tables */
----if (attr->ShouldOutput()) {
------has_intresting_columns = true;
--while (it.IsValid() && row < no_obj) 
----if (it.PackrowStarted() || first_row_for_vc) 
------for (auto &attr : attrs) attr->term.vc->LockSourcePacks(it);
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
--------if (vc->IsNull(it))
----------IsNullImpl
------------IsNull//tianmu_attr.h
--------------pack = row2pack(obj);
--------------get_dpn(pack);
--------------if (!dpn.Trivial()) {
----------------get_pack(pack)->IsNull(row2offset(obj));
------------------IsNull//pack
--------------------return ((nulls_ptr_[locationInPack >> 5] & ((uint32_t)(1) << (locationInPack % 32))) != 0);
----------data_ptr->SetToNull();
------------null_ = true; //class TianmuDataType
--------else
----------vc->GetNotNullValueString(*data_ptr, it);//SingleColumn
------------col_->GetNotNullValueString(mit[dim_], s);
--------------TempTable::GetNotNullValueString
----------------TempTable::Attr::GetValueString
----ResultSender::SendRow
--//end while
--for (auto &attr : attrs) {
----attr->term.vc->UnlockSourcePacks();
--}
```






