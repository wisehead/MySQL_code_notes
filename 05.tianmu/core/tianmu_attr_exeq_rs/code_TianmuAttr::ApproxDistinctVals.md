#1.TianmuAttr::ApproxDistinctVals

```
TianmuAttr::ApproxDistinctVals
--LoadPackInfo
--max_obj = NumOfObj(); 
--if (NumOfNulls() > 0 || outer_nulls_possible) {
----//-
--} else if (f)
----//-
--if (TypeName() == common::ColumnType::DATE) {
----//-
--} else if (TypeName() == common::ColumnType::YEAR) {
----//-
--} else if (GetPackType() == common::PackType::INT && TypeName() != common::ColumnType::REAL &&
             TypeName() != common::ColumnType::FLOAT) {
----//-
--} else if (TypeName() == common::ColumnType::REAL || TypeName() == common::ColumnType::FLOAT) {
----//-
--} else if (TypeName() == common::ColumnType::STRING || TypeName() == common::ColumnType::VARCHAR ||
             TypeName() == common::ColumnType::LONGTEXT) {
----for (uint p = 0; p < SizeOfPack(); p++) {  // max len of nonempty packs
------if (f == nullptr || !f->IsEmpty(p))
--------max_len = std::max(max_len, GetActualSize(p));
----}   
----if (max_len > 0 && max_len < 6)
      no_dist += int64_t(256) << ((max_len - 1) * 8);
    else if (max_len > 0)
      no_dist = max_obj;  // default
    else if (max_len == 0 && max_obj)
      no_dist++;                       
```