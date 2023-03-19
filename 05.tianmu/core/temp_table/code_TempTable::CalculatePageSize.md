#1.TempTable::CalculatePageSize

```
TempTable::CalculatePageSize
--for (uint i = 0; i < attrs.size(); i++)
----if (attrs[i]->TypeName() == common::ColumnType::BIN || attrs[i]->TypeName() == common::ColumnType::BYTE ||
        attrs[i]->TypeName() == common::ColumnType::VARBYTE || attrs[i]->TypeName() == common::ColumnType::LONGTEXT ||
        attrs[i]->TypeName() == common::ColumnType::STRING || attrs[i]->TypeName() == common::ColumnType::VARCHAR)
      size_of_one_record += attrs[i]->Type().GetInternalSize() + 4;  // 4 bytes describing length
----else
------size_of_one_record += attrs[i]->Type().GetInternalSize();
--SetOneOutputRecordSize(size_of_one_record);
--if (mem_scale == -1)
----mem_scale = mm::TraceableObject::MemorySettingsScale();
------ha_tianmu_engine_->getResourceManager()->GetMemoryScale();
--------res_manage_policy_->estimate()
----------MagMemoryPolicy::estimate() override { return m_scale; }//6
--switch (mem_scale) {
----case 6:
------cache_size = 1l << 30;
------break;  // 1GB
--if (cache_size / size_of_one_record <= (uint64_t)new_no_obj) {
    raw_size = uint((cache_size - 1) / size_of_one_record);  // minus 1 to avoid overflow
  }
--for (uint i = 0; i < attrs.size(); i++) attrs[i]->page_size = raw_size;
--return raw_size;
```