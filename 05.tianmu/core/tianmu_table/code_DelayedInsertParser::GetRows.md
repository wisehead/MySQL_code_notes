#1.DelayedInsertParser::GetRows

```
GetRows
--start_row = attrs[0]->NumOfObj();
--value_buffers.reserve(attrs.size());
--for (size_t i = 0; i < attrs.size(); i++) {
----value_buffers.emplace_back(pack_size, pack_size * 128);
--for (no_of_rows_returned = 0; no_of_rows_returned < no_of_rows; no_of_rows_returned++) {
----auto ptr = (*vec)[processed].get();
      // int  tid = *(int32_t *)ptr;
      ptr += sizeof(int32_t);
      std::string path(ptr);
      ptr += path.length() + 1;
      utils::BitSet null_mask(attrs.size(), ptr);
      ptr += null_mask.data_size();
----for (uint i = 0; i < attrs.size(); i++) 
------auto &vc = value_buffers[i];
        if (null_mask[i]) {
          vc.ExpectedNull(true);
          continue;
        }
        auto &attr(attrs[i]);
------switch (attr->GetPackType())
--------case common::PackType::STR: 
--------case common::PackType::INT:
----------if (attr->Type().Lookup()) {
----------else
------------int64_t *buf = reinterpret_cast<int64_t *>(vc.Prepare(sizeof(int64_t)));
------------*buf = *(int64_t *)ptr;
------------if (attr->GetIfAutoInc()) 
--------------//
------------vc.ExpectedSize(sizeof(int64_t));
              ptr += sizeof(int64_t);
----for (auto &vc : value_buffers) {
      vc.Commit();
----processed++;
----InsertIndex(value_buffers, start_row)
```