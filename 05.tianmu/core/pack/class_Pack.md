#1.class Pack

```cpp
// table of modes:
//  0 - trivial data: all values are derivable from the statistics, or nulls
//  only,
//      the pack physically doesn't exist, only statistics
//  1 - unloaded (on disc)
//  2 - loaded to memory
//  3 - no data yet, empty pack

class Pack : public mm::TraceableObject {
 protected:
  ColumnShare *col_share_ = nullptr;
  size_t bitmap_size_;
  DPN *dpn_ = nullptr;

  /*
  The actual storage form of a bitmap is an array of type int32.
  The principle is to use the 32-bit space occupied by a value of type int32 to
  store and record the states of these 32 values using 0 or 1.
  The total number of bits in the bitmap is equal to the total number of rows in the pack,
  and the position of the data in the pack and the position in the bitmap are also one-to-one correspondence
  This can effectively save space.
  */
  std::unique_ptr<uint32_t[]> nulls_ptr_;    // Null bitmap
  std::unique_ptr<uint32_t[]> deletes_ptr_;  // deleted bitmap
};  
```