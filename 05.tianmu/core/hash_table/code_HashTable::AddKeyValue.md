#1.HashTable::AddKeyValue

```
HashTable::AddKeyValue
--unsigned int crc_code = HashValue(key_buffer.c_str(), key_buffer.size());
--row = crc_code % rows_count_;
--do {
---- *cur_t = buffer_ + row * total_width_;
----int64_t *multiplier = (int64_t *)(cur_t + multi_offset_);
----if (*multiplier != 0) {
------//--
----else
------*multiplier = 1;
------std::memcpy(cur_t, key_buffer.c_str(), key_buf_width_);
------rows_of_occupied_++;
------return row;
```