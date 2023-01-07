#1.class PackInt

```cpp
class PackInt final : public Pack {
  bool is_real_ = false;
  struct {
    int64_t operator[](size_t n) const {
      switch (value_type_) {
        case 8:
          return ptr_int64_[n];
        case 4:
          return ptr_int32_[n];
        case 2:
          return ptr_int16_[n];
        case 1:
          return ptr_int8_[n];
        default:
          TIANMU_ERROR("bad value type in pakcN");
      }
    }
    bool empty() const { return ptr_ == nullptr; }

   public:
    unsigned char value_type_;
    union {
      uint8_t *ptr_int8_;
      uint16_t *ptr_int16_;
      uint32_t *ptr_int32_;
      uint64_t *ptr_int64_;
      double *ptr_double_;
      void *ptr_;
    };
  } data_ = {};
};
```