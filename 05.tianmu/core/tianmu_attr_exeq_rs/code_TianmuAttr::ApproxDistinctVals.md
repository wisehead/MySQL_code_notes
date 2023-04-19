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
----                          
```