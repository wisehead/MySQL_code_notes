#1.ValueParserForText::Parse

```
ValueParserForText::Parse
--EatWhiteSigns(val, len);
--if (at == common::ColumnType::UNK) {
----//nothing
--if (core::ATI::IsIntegerType(at)) {
----ret = ParseBigInt(tianmu_s, tianmu_n);
----if (at == common::ColumnType::BYTEINT) {
----} else if (at == common::ColumnType::SMALLINT) {
----} else if (at == common::ColumnType::MEDIUMINT) {
----} else if (at == common::ColumnType::INT) {
----tianmu_n.is_double_ = false;
----tianmu_n.scale_ = 0;
----tianmu_n.value_ = v;

```