#1.class MysqlExpression

```cpp
// Wrapper for MySQL expression tree
class MysqlExpression {
 public:
  // map which tells how to replace Item_field's with Item_tianmufield
  using Item2VarID = std::map<Item *, VarID>;
  using TypOfVars = std::map<VarID, DataType>;  // map of types of variables
  using tianmu_fields_cache_t = std::map<VarID, std::set<Item_tianmufield *>>;
  using value_or_null_info_t = std::pair<ValueOrNull, ValueOrNull *>;
  using var_buf_t = std::map<VarID, std::vector<value_or_null_info_t>>;
  using SetOfVars = std::set<VarID>;  // set of IDs of variables occuring in
  enum class StringType { STRING_NOTSTRING, STRING_TIME, STRING_NORMAL };
  
private:
  DataType type;  // type of result of the expression  
  Item *item;
  Item_result mysql_type;
  uint decimal_precision, decimal_scale;
  Item2VarID *item2varid;
  tianmu_fields_cache_t tianmu_fields_cache;
  SetOfVars vars;  // variable IDs in the expression, same as in tianmu_fields_cache;
                   // filled in TransformTree
  bool deterministic;
};
```