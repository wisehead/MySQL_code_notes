#1.TianmuTable::MergeDeltaTable

```
TianmuTable::MergeDeltaTable
--expected_count = m_delta->CountRecords() < tianmu_sysvar_merge_rocks_expected_count
                              ? m_delta->CountRecords()
                              : tianmu_sysvar_merge_rocks_expected_count;
--uchar key_buf[sizeof(uint32_t)];
--uint32_t delta_id = m_delta->GetDeltaTableID();
--index::be_store_index(key_buf, delta_id);                              
--index::be_store_index(key_buf, delta_id);
--rocksdb::Slice prefix((char *)key_buf, sizeof(uint32_t));
--cf_handle = m_delta->GetCFHandle();
--std::unique_ptr<rocksdb::Iterator> iter(m_tx->KVTrans().GetDataIterator(r_opts, cf_handle));
--iter->Seek(prefix);
--while (expected_count > 0 && iter->Valid() && iter->key().starts_with(prefix)) {
----key = iter->key();
----uint64_t row_id = index::be_to_uint64(reinterpret_cast<const uchar *>(key.data()) + sizeof(uint32_t));
----value = iter->value();
----std::unique_ptr<char[]> buf(new char[value.size()]);
----std::memcpy(buf.get(), value.data(), value.size());
----auto type = *reinterpret_cast<RecordType *>(buf.get());
----auto load_num = *reinterpret_cast<uint32_t *>(buf.get() + sizeof(RecordType));
----if (type == RecordType::kInsert) {
        insert_records.emplace_back(std::move(buf));
----m_tx->KVTrans().SingleDeleteData(cf_handle, iter->key());  // todo(dfx): change to DeleteRange
----expected_count -= load_num;
    m_delta->merge_id.fetch_add(load_num);
    m_delta->stat.read_cnt++;
    m_delta->stat.read_bytes += value.size();
----if (insert_records.size() >= static_cast<std::size_t>(tianmu_sysvar_insert_max_buffered)) {
------insert_num += AsyncParseInsertRecords(&iop, &insert_records);
----iter->Next();
--if (!insert_records.empty()) 
----insert_num += AsyncParseInsertRecords(&iop, &insert_records);
```