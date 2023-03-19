#1.ResultSender::SendRecord

```
ResultSender::SendRecord
--while ((item = li++)) {
----types::TianmuDataType &tianmu_dt(*r[col_id]);
----switch (item->type()) {
------case Item::FIELD_ITEM:  // regular select
--------ifield = (Item_field *)item;
--------f = ifield->result_field;
--------if (buf_lens[col_id] != 0) {
----------bitmap_set_bit(f->table->write_set, f->field_index);
----------auto is_null = Engine::ConvertToField(f, tianmu_dt, nullptr);
----------SetFieldState
------------if (is_null) {
------------else
--------------if (field->real_maybe_null())
----------------field->set_notnull();
```