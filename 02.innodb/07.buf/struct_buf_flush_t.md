#1.struct buf_flush_t

```cpp
/** Flags for flush types */
enum buf_flush_t {
  BUF_FLUSH_LRU = 0,     /*!< flush via the LRU list */
  BUF_FLUSH_LIST,        /*!< flush via the flush list
                         of dirty blocks */
  BUF_FLUSH_SINGLE_PAGE, /*!< flush via the LRU list
                         but only a single page */
  BUF_FLUSH_N_TYPES      /*!< index of last element + 1  */
};
```