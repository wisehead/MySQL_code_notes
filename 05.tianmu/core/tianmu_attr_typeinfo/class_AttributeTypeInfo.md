#1.class AttributeTypeInfo

```cpp
class AttributeTypeInfo {
 public:
  enum class enumATI {
    NOT_NULL = 0,
    AUTO_INC,
    BLOOM_FILTER,
  };
 private:
  common::ColumnType attrt_;
  common::PackFmt fmt_;
  uint precision_;
  int scale_;
  DTCollation collation_;
  std::string field_name_;

  std::bitset<std::numeric_limits<unsigned char>::digits> flag_;
};
```