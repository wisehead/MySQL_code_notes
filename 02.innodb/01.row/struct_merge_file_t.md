#1.struct merge_file_t

```cpp
/** Information about temporary files used in merge sort */
struct merge_file_t {
  int fd;            /*!< file descriptor */
  ulint offset;      /*!< file offset (end of file) */
  ib_uint64_t n_rec; /*!< number of records in the file */
};
```