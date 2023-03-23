#1.ParsingStrategy::GetOneRow

```
ParsingStrategy::GetOneRow
--if (!prepared_) 
----ParsingStrategy::GetEOL
----prepared_ = true;
--if (buf == buf_end)
    return ParsingStrategy::ParseResult::EOB;
--uint n_fields = table_->s->fields;
--restore_record(table_, s->default_values);
----memcpy((A)->record[0],(A)->B,(size_t) (A)->s->reclength)
--for (i = 0; i < n_fields; i++) {
----Field *field = table_->field[i];
----if (!first_row_prepared_) {
------str = new (thd_->mem_root) String(MAX_FIELD_WIDTH);
-------String *res = field->val_str(str);
---------Field_long::val_str
------vec_field_Str_list_.push_back(str);
------vec_field_num_to_index_.push_back(0);
------map_field_name_to_index_[field_name] = i;
----vec_ptr_field.emplace_back(str->ptr(), str->length());
--while ((item = it++)) {
----SearchUnescapedPatternNoEOL   
----ParsingStrategy::ReadField   
```