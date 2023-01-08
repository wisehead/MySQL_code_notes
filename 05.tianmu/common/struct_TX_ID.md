#1.struct TX_ID

```cpp
// Transaction ID is unique for each transaction and grows monotonically.
struct TX_ID final {
  union {
    uint64_t v;
    struct {
      uint32_t v1;
      uint32_t v2;
    };
  };

  TX_ID(uint64_t v = UINT64_MAX) : v(v) {}
  TX_ID(uint32_t v1, uint32_t v2) : v1(v1), v2(v2) {}
  std::string ToString() const;
  bool operator<(const TX_ID &rhs) const { return v < rhs.v; }
};

const TX_ID MAX_XID = std::numeric_limits<uint64_t>::max();
```