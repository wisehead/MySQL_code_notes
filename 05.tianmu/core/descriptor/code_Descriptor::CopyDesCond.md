#1.Descriptor::CopyDesCond

```
Descriptor::CopyDesCond
--if (IsType_AttrValOrAttrValVal()) 
----common::ColumnType column_type = attr.vc->Type().GetTypeName();
----bool is_lookup = attr.vc->Type().Lookup();
----if (((column_type == common::ColumnType::VARCHAR || column_type == common::ColumnType::STRING) && is_lookup) 	||ATI::IsNumericType(column_type) || ATI::IsDateTimeType(column_type))
------pack_type = common::PackType::INT;
```