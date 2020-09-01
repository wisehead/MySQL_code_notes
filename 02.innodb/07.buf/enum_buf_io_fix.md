#1.enum buf_io_fix

```cpp
/** Flags for io_fix types */
enum buf_io_fix {
  BUF_IO_NONE = 0, /**< no pending I/O */
  BUF_IO_READ,     /**< read pending */
  BUF_IO_WRITE,    /**< write pending */
  BUF_IO_PIN       /**< disallow relocation of
                   block and its removal of from
                   the flush_list */
};
```