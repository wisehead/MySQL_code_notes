#1.struct DPN

```cpp
// Data Pack Node. Same layout on disk and in memory
struct DPN final {
 public:
  uint8_t used : 1;    // occupied or not
  uint8_t local : 1;   // owned by a write transaction, thus to-be-commit
  uint8_t synced : 1;  // if the pack data in memory is up to date with the
                       // version on disk
  uint8_t null_compressed : 1;
  uint8_t delete_compressed : 1;
  uint8_t data_compressed : 1;
  uint8_t no_compress : 1;
  uint8_t paddingBit : 1;  // Memory aligned padding has no practical effect
  uint8_t padding[7];      // Memory aligned padding has no practical effect

  uint32_t base;          // index of the DPN from which we copied, used by local pack
  uint32_t numOfRecords;  // number of records
  uint32_t numOfNulls;    // number of nulls
  uint32_t numOfDeleted;  // number of deleted

  uint64_t dataAddress;  // data start address
  uint64_t dataLength;   // data length

  common::TX_ID xmin;  // creation trx id
  common::TX_ID xmax;  // delete trx id
  union {
    int64_t min_i;
    double min_d;
    char min_s[8];
  };
  union {
    int64_t max_i;
    double max_d;
    char max_s[8];
  };
  union {
    int64_t sum_i;
    double sum_d;
    uint64_t maxlen;
  };
 private:
  // a tagged pointer, 16 bits as ref count.
  // Only read-only dpn uses it for ref counting; local dpn is managed only by
  // one write session
  std::atomic_ulong tagged_ptr;
};
```