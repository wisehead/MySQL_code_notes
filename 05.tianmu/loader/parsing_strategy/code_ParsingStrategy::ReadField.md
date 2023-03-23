#1.ParsingStrategy::ReadField

```
ParsingStrategy::ReadField
--if (string_qualifier_ && *val_beg == string_qualifier_ && completed_row) {
----//nothing
--else
----val_start = const_cast<char *>(val_beg);
----val_len = ptr - val_beg;
--switch (val_len) {
----default:
------break;
--Item *real_item = item->real_item();
--if (isnull) {
----//nothing
--} else {
----if (real_item->type() == Item::FIELD_ITEM) {
------Field *field = ((Item_field *)real_item)->field;
------ield->set_notnull();
------field->store(val_start, val_len, char_info);
--------Field_long::store
------if (!first_row_prepared_) {
        std::string field_name(field->field_name);
        index_of_field = map_field_name_to_index_[field_name];
        vec_field_num_to_index_[field_index_in_field_list] = index_of_field;
------vec_ptr_field[index_of_field] = std::make_pair(val_start, val_len);
------++field_index_in_field_list;
------
```