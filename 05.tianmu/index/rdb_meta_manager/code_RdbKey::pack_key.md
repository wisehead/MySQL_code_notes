#1.RdbKey::pack_key

```
RdbKey::pack_key
--key.clear();
  info.clear();
  key.write_uint32(index_pos_);
--if (index_ver_ > static_cast<uint16_t>(IndexInfoType::INDEX_INFO_VERSION_INITIAL))
    info.write_uint16(0);
  size_t pos = info.length();
--for (uint i = 0; i < fields.size(); i++) {
----switch (cols_[i].col_type)
------case MYSQL_TYPE_LONGLONG:
      case MYSQL_TYPE_LONG:
      case MYSQL_TYPE_INT24:
      case MYSQL_TYPE_SHORT:
      case MYSQL_TYPE_TINY:

      case MYSQL_TYPE_DOUBLE:
      case MYSQL_TYPE_FLOAT:
      case MYSQL_TYPE_NEWDECIMAL:
      case MYSQL_TYPE_TIMESTAMP:
      case MYSQL_TYPE_TIME:
      case MYSQL_TYPE_DATE:
      case MYSQL_TYPE_DATETIME:
      case MYSQL_TYPE_NEWDATE:
      case MYSQL_TYPE_DATETIME2:
      case MYSQL_TYPE_TIMESTAMP2:
      case MYSQL_TYPE_TIME2:
      case MYSQL_TYPE_YEAR: {
        pack_field_number(key, fields[i], cols_[i].col_flag);
        break;
```