#1.JustATable::GetComplexValue

```
JustATable::GetComplexValue
--ColumnType ct = GetColumnType(attr);
--if (ct.GetTypeName() == common::ColumnType::TIMESTAMP) {
----//--
--if (ct.IsString()) {
----GetTable_S(s, obj, attr);
------TianmuTable::GetTable_S
--------m_attrs[attr]->GetValueString(obj);
----------TianmuAttr::GetValueString
```