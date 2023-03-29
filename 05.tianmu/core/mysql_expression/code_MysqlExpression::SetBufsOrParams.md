#1.MysqlExpression::SetBufsOrParams

```
MysqlExpression::SetBufsOrParams
--for (auto &it : tianmu_fields_cache) {
----auto buf_set = bufs->find(it.first);
----if (buf_set != bufs->end()) {
------for (auto &tianmufield : it.second) {
--------ValueOrNull *von;
--------tianmufield->SetBuf(von);
--------buf_set->second.push_back(value_or_null_info_t(ValueOrNull(), von));

```