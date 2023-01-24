#1.class ResultSender

```cpp
class ResultSender {

 protected:
  THD *thd;
  Query_result *res;
  std::map<int, Item *> items_backup;
  uint *buf_lens;
  List<Item> &fields;
  bool is_initialized;
  int64_t *offset;
  int64_t *limit;
  int64_t rows_sent;
  int64_t affect_rows;

};

```