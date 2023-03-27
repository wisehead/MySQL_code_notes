#1.ColumnBinEncoder::EncoderText_UTF::Encode

```
ColumnBinEncoder::EncoderText_UTF::Encode
--vc->GetNotNullValueString(s, mit);
----TianmuAttr::GetNotNullValueString
--if (update_stats) {
----if (!min_max_set) {
------maxs.PersistentCopy(s);
------mins.PersistentCopy(s);
------min_max_set = true;
```
