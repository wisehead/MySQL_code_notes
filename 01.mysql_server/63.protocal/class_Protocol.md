#1.Protocol

```cpp
class Protocol
{
protected:
  THD    *thd;
  String *packet;
  String *convert;
  uint field_pos;
#ifndef DBUG_OFF
  enum enum_field_types *field_types;
#endif
  uint field_count;
#ifndef EMBEDDED_LIBRARY
  bool net_store_data(const uchar *from, size_t length);
#else
  virtual bool net_store_data(const uchar *from, size_t length);
  char **next_field;
  MYSQL_FIELD *next_mysql_field;
  MEM_ROOT *alloc;
#endif
  enum enum_protocol_type
  {
    /*
      Before adding a new type, please make sure
      there is enough storage for it in Query_cache_query_flags.
    */
    PROTOCOL_TEXT= 0, PROTOCOL_BINARY= 1, PROTOCOL_LOCAL= 2
  };
};
```