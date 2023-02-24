#1.TianmuTableIndex::InsertIndex

```
TianmuTableIndex::InsertIndex
--rocksdb_key_->pack_key(key, fields, value);
--CheckUniqueness
--value.write_uint64(row);
--tx->KVTrans().Put(cf, {(const char *)key.ptr(), key.length()}, {(const char *)value.ptr(), value.length()});
```