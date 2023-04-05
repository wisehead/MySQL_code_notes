#1.Engine::EncodeInsertRecord

```
Engine::EncodeInsertRecord
--size = blobs > 0 ? 4_MB : 128_KB;//buf size
--DeltaRecordHeadForInsert deltaRecord(DELTA_RECORD_NORMAL, col);
--ptr = deltaRecord.recordEncode(ptr);
--for (uint i = 0; i < col; i++) {
----Field *f = field[i];
----if (f->flags & BLOB_FLAG)
        length = dynamic_cast<Field_blob *>(f)->get_length();
----else
        length = f->row_pack_length();
----length += 8;
----size_t used = ptr - buf.get();
----if (size - used < length) {
------//--buf内存不够，继续扩
----if (f->is_null()) {
------//--
----ptr = FiledToStr(ptr, f, &deltaRecord, i, thd);
--std::memcpy(buf.get() + deltaRecord.null_offset_, deltaRecord.null_mask_.data(), deltaRecord.null_mask_.data_size());
--size = ptr - buf.get();
```