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
----case MYSQL_TYPE_VARCHAR:
    case MYSQL_TYPE_TINY_BLOB:
    case MYSQL_TYPE_MEDIUM_BLOB:
    case MYSQL_TYPE_LONG_BLOB:
    case MYSQL_TYPE_BLOB:
    case MYSQL_TYPE_VAR_STRING:
    case MYSQL_TYPE_STRING: {
      String str;
      field->val_str(&str);
      std::memcpy(ptr, str.ptr(), str.length());
      deltaRecord->field_len_[col_num] = str.length();
      ptr += str.length();
    } break;
```