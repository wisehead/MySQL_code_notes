#1.Engine::ConvertToField

```
Engine::ConvertToField
--if (tianmu_item.IsNull())
----std::memset(field->ptr, 0, 2);
----field->set_null();
----return true;
--field->set_notnull();
----m_null_ptr[row_offset]&= (uchar) ~null_bit;
--switch (field->type()) {
----case MYSQL_TYPE_VARCHAR: {
------types::BString &str_val = (types::BString &)tianmu_item;
------if (str_val.size() > field->field_length)
--------throw common::DatabaseException("Incorrect field size: " + std::to_string(str_val.size()));
------if (field->field_length <= 255)
--------str_val.PutVarchar((char *&)field->ptr, 1, false);//字符串第一个字节加上length信息
      break;
----default:
------switch (tianmu_item.Type()) 
--------case common::ColumnType::BYTEINT:
        case common::ColumnType::SMALLINT:
        case common::ColumnType::MEDIUMINT:
        case common::ColumnType::INT:
        case common::ColumnType::BIGINT:
        case common::ColumnType::REAL:
        case common::ColumnType::FLOAT:
        case common::ColumnType::NUM:
        case common::ColumnType::BIT:
          switch (field->type()) {
------------case MYSQL_TYPE_LONG:
--------------*reinterpret_cast<int *>(field->ptr) = (int)(int64_t)((types::TianmuNum &)(tianmu_item));
--------------break;

```