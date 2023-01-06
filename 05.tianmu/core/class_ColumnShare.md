#1.class ColumnShare

```cpp
class ColumnShare final {
  friend class TianmuAttr;
...
...
 private:
  TableShare *owner;
  const fs::path m_path;
  ColumnType ct;
  int dn_fd{-1};
  DPN *start;
  size_t capacity{0};  // current capacity of the dn array
  common::PackType pt;
  uint32_t col_id;
  std::string field_name_;
  struct seg {
    uint64_t offset;
    uint64_t len;
    common::PACK_INDEX idx;
  };
  std::list<seg> segs;  // only used by write session so no mutex is needed

  bool has_filter_cmap = false;
  bool has_filter_hist = false;
  bool has_filter_bloom = false;
};  
```