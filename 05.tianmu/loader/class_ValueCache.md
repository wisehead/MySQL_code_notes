#1.class ValueCache

```cpp
class ValueCache final {
 private:
  void *data_ = nullptr;
  size_t size_ = 0;
  size_t capacity_ = 0;
  size_t value_count_;
  size_t expected_size_ = 0;
  bool expected_null_ = false;

  std::vector<size_t> values_;
  std::vector<bool> nulls_;
  size_t null_cnt_ = 0;

  int64_t min_i_, max_i_, sum_i_;
  double min_d_, max_d_, sum_d_;
};
```