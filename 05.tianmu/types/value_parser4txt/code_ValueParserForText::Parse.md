#1.ValueParserForText::Parse

```
ValueParserForText::Parse
--EatWhiteSigns(val, len);
--if (at == common::ColumnType::UNK) {
----//nothing
--if (core::ATI::IsIntegerType(at)) {
----ret = ParseBigInt(tianmu_s, tianmu_n);
```