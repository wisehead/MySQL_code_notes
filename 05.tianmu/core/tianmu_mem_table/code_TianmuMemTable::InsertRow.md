#1.TianmuMemTable::InsertRow

```cpp
TianmuMemTable::InsertRow
--  // insert rowset data
  int64_t row_id = next_insert_id_++;
  if (row_id < next_load_id_)
    next_load_id_ = row_id;

  uchar key[32];
  size_t key_pos = 0;
  index::KVTransaction kv_trans;
  index::be_store_index(key + key_pos, mem_id_);
  key_pos += sizeof(uint32_t);
  index::be_store_byte(key + key_pos, static_cast<uchar>(RecordType::kInsert));
  key_pos += sizeof(uchar);
  index::be_store_uint64(key + key_pos, row_id);
  key_pos += sizeof(uint64_t);
  kv_trans.PutData(cf_handle_, {(char *)key, key_pos}, {buf.get(), size});
  kv_trans.Commit();
  stat.write_cnt++;
  stat.write_bytes += size;
```