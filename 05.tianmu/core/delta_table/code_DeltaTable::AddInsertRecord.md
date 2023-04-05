#1.DeltaTable::AddInsertRecord

```
DeltaTable::AddInsertRecord
--uchar key[sizeof(uint32_t) + sizeof(uint64_t)];
--// table id
  index::be_store_index(key + key_pos, delta_tid_);
  key_pos += sizeof(uint32_t);
  // row id
  index::be_store_uint64(key + key_pos, row_id);
  key_pos += sizeof(uint64_t);
--kv_trans.PutData(cf_handle_, {(char *)key, key_pos}, {buf.get(), size});
```