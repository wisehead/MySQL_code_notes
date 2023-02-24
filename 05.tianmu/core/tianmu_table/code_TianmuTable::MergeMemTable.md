#1.TianmuTable::MergeMemTable

```
TianmuTable::MergeMemTable
--auto index_table = ha_tianmu_engine_->GetTableIndex(share->Path());
--auto cf_handle = m_mem_table->GetCFHandle();
    uint32_t mem_id = m_mem_table->GetMemID();
    index::be_store_index(entry_key + key_pos, mem_id);
    key_pos += sizeof(uint32_t);
    index::be_store_byte(entry_key + key_pos, static_cast<uchar>(TianmuMemTable::RecordType::kInsert));
    key_pos += sizeof(uchar);
    rocksdb::Slice entry_slice((char *)entry_key, key_pos);
--index::be_store_index(upper_key + upper_pos, mem_id);
    upper_pos += sizeof(uint32_t);
    uchar upkey = static_cast<int>(TianmuMemTable::RecordType::kInsert) + 1;
    index::be_store_byte(upper_key + upper_pos, upkey);
    upper_pos += sizeof(uchar);
    rocksdb::Slice upper_slice((char *)upper_key, upper_pos);
--m_mem_table->next_load_id_ = m_mem_table->next_insert_id_.load();
--std::unique_ptr<rocksdb::Iterator> iter(m_tx->KVTrans().GetDataIterator(ropts, cf_handle));
--iter->Seek(entry_slice);
--while (iter->Valid()) {
      auto value = iter->value();
      std::unique_ptr<char[]> buf(new char[value.size()]);
      std::memcpy(buf.get(), value.data(), value.size());
      vec.emplace_back(std::move(buf));
      m_tx->KVTrans().SingleDeleteData(cf_handle, iter->key());
      m_mem_table->stat.read_cnt++;
      m_mem_table->stat.read_bytes += value.size();

      iter->Next();
      if (vec.size() >= static_cast<std::size_t>(tianmu_sysvar_insert_max_buffered))
        break;
    }
--if (iter->Valid() && iter->key().starts_with(entry_slice)) {
----m_mem_table->next_load_id_ = index::be_to_uint64((uchar *)iter->key().data() + key_pos);
--DelayedInsertParser parser(m_attrs, &vec, share->PackSize(), index_table);
--while (no_of_rows_returned == to_prepare);
----to_prepare = share->PackSize() - (int)(m_attrs[0]->NumOfObj() % share->PackSize());
----no_of_rows_returned = parser.GetRows(to_prepare, vcs);
```