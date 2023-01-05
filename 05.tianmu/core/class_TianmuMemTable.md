#1.class TianmuMemTable

```cpp
class TianmuMemTable {
 public:
  enum class RecordType { RecordType_min, kSchema, kInsert, kUpdate, kDelete, RecordType_max };
...
...
  struct Stat {
    std::atomic_ulong write_cnt{0};
    std::atomic_ulong write_bytes{0};
    std::atomic_ulong read_cnt{0};
    std::atomic_ulong read_bytes{0};
  } stat;
  std::atomic<std::int64_t> next_load_id_ = 0;
  std::atomic<std::int64_t> next_insert_id_ = 0;

 private:
  std::string fullname_;
  uint32_t mem_id_ = 0;
  rocksdb::ColumnFamilyHandle *cf_handle_ = nullptr;
};  

```