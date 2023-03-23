#1.LoadParser::GetPackrow

```
LoadParser::GetPackrow(
--for (uint att = 0; att < attrs_.size(); att++) {
----if (last_pack_size_.size() > att)
------init_capacity = static_cast<int64_t>(last_pack_size_[att] * 1.1) + 128;
----else
------init_capacity = pack_size_ * max_value_size + 512;
------if (core::ATI::IsStringType(attrs_[att]->TypeName()) && attrs_[att]->Type().GetPrecision() < max_value_size)
--------max_value_size = attrs_[att]->Type().GetPrecision();
------init_capacity = pack_size_ * max_value_size + 512;
----value_buffers.emplace_back(pack_size_, init_capacity);
--for (no_of_rows_returned = 0; no_of_rows_returned < no_of_rows; no_of_rows_returned++) {
----if (!MakeRow(value_buffers))
------break;
```