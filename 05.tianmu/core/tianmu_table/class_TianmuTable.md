#1.class TianmuTable

```cpp
class TianmuTable final : public JustATable {
 public:
  std::unique_lock<std::mutex> write_lock;
 private:
  TableShare *share;
  std::string db_name;

  Transaction *m_tx = nullptr;

  std::vector<std::unique_ptr<TianmuAttr>> m_attrs;
  std::shared_ptr<TianmuMemTable> m_mem_table;

  std::vector<common::TX_ID> m_versions;

  fs::path m_path;

  size_t no_rejected_rows = 0;
  uint64_t no_loaded_rows = 0;
  uint64_t no_dup_rows = 0;   
}
```