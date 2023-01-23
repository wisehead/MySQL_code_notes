#1.class TianmuNum

```cpp
class TianmuNum : public ValueBasic<TianmuNum> {
  friend class ValueParserForText;
  friend class Engine;

 private:
  static constexpr int MAX_DEC_PRECISION = 18;
  int64_t value_;
  ushort scale_;  // means 'scale' actually
  bool is_double_;
  bool is_dot_;
  common::ColumnType attr_type_;

 public:
  const static ValueTypeEnum value_type_ = ValueTypeEnum::NUMERIC_TYPE;
};
```