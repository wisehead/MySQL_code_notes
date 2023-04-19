#1.ValueMatching_HashTable::FindCurrentRow

```
ValueMatching_HashTable::FindCurrentRow
--crc_code = HashValue(input_buffer, matching_width);
--unsigned int ht_pos = (crc_code & ht_mask);
--unsigned int row_no = ht[ht_pos];
--if (row_no == 0xFFFFFFFF) {  // empty hash position
    if (!add_if_new) {
      row = common::NULL_VALUE_64;
      return false;
    }
    row_no = no_rows;
    ht[ht_pos] = row_no;
--while (row_no < no_rows) {
----//-
--row = row_no;
--int64_t new_row = t.AddEmptyRow();  // 0 is set as a "NextPos"
--ASSERT(new_row == row, "wrong row number");
--std::memcpy(t.GetRow(row), input_buffer, input_buffer_width);
--no_rows++;
```