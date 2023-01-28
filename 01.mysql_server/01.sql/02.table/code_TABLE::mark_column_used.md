#1.TABLE::mark_column_used

```
TABLE::mark_column_used
--switch (mark)
----case MARK_COLUMNS_READ:
------bitmap_set_bit(read_set, field->field_index);
------// Update covering_keys and merge_keys based on all fields that are read:
------covering_keys.intersect(field->part_of_key);
------merge_keys.merge(field->part_of_key);
```
