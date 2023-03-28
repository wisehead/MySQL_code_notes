#1.HashTable::SetTupleValue

```
HashTable::SetTupleValue
--if (column_size_[col] == 4) {
----if (value == common::NULL_VALUE_64)
      *((int *)(buffer_ + row * total_width_ + column_offset_[col])) = 0;
----else
      *((int *)(buffer_ + row * total_width_ + column_offset_[col])) = int(value + 1);
```