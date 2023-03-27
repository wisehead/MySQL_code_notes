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
--common::strnxfrm(collation, buf, size - sizeof(uint32_t), (uchar *)s.GetDataBytesPointer(), s.len_);
--uint32_t length = s.len_ + 1;
--std::memcpy(buf + size - sizeof(uint32_t), &length, sizeof(uint32_t));
--
```
