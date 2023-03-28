#1.MysqlExpression::ItemString2ValueOrNull

```
MysqlExpression::ItemString2ValueOrNull
--String *ret = item->val_str(&string_result);
--if (ret != nullptr) {
----if (ATI::IsDateTimeType(a_type)) {
------//--
----else
------val->SetString(p, len);
------val->MakeStringOwner();
```