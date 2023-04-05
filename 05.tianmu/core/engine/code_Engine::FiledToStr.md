#1.Engine::FiledToStr

```
Engine::FiledToStr
--switch (field->type()) {
----case MYSQL_TYPE_TINY:
    case MYSQL_TYPE_SHORT:
    case MYSQL_TYPE_LONG:
    case MYSQL_TYPE_INT24:
    case MYSQL_TYPE_LONGLONG: {
------int64_t v = field->val_int();
------common::PushWarningIfOutOfRange(thd, std::string(field->field_name), v, field->type(),
                                      field->flags & UNSIGNED_FLAG);
------*reinterpret_cast<int64_t *>(ptr) = v;
------deltaRecord->field_len_[col_num] = sizeof(int64_t);
------ptr += sizeof(int64_t);                                      
```