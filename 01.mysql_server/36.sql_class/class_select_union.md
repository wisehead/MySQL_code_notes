#1.class select_union

```cpp
class select_union :public select_result_interceptor
{
  TMP_TABLE_PARAM tmp_table_param;
public:
  TABLE *table;

  select_union() :table(0) {}
  int prepare(List<Item> &list, SELECT_LEX_UNIT *u);
  bool send_data(List<Item> &items);
  bool send_eof();
  bool flush();
  void cleanup();
  bool create_result_table(THD *thd, List<Item> *column_types,
                           bool is_distinct, ulonglong options,
                           const char *alias, bool bit_fields_as_long,
                           bool create_table);
  friend bool mysql_derived_create(THD *thd, LEX *lex, TABLE_LIST *derived);
};
```