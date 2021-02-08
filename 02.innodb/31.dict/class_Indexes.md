#1.class Indexes

```cpp

class Indexes : public Object_table_impl {
    // 表定义
    enum enum_fields {
    FIELD_ID,
    FIELD_TABLE_ID,
    FIELD_NAME,
    FIELD_TYPE,
    FIELD_ALGORITHM,
    FIELD_IS_ALGORITHM_EXPLICIT,
    FIELD_IS_VISIBLE,
    FIELD_IS_GENERATED,
    FIELD_HIDDEN,
    FIELD_ORDINAL_POSITION,
    FIELD_COMMENT,
    FIELD_OPTIONS,
    FIELD_SE_PRIVATE_DATA,
    FIELD_TABLESPACE_ID,
    FIELD_ENGINE,
    NUMBER_OF_FIELDS  // Always keep this entry at the end of the enum
  };
  ...
}
```