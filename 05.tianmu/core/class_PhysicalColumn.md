#1.class PhysicalColumn

```cpp
//! A column in a table. Values contained in it exist physically on disk and/or
//! in memory and are divided into datapacks
class PhysicalColumn : public Column {
 public:
  enum class phys_col_t { ATTR, kTianmuAttr };

 private:
  bool is_unique;
  bool is_unique_updated;
}

```