#1.page_cur_t

```cpp
struct page_cur_t{
    byte*       rec;    /*!< pointer to a record on page */
    buf_block_t*    block;  /*!< pointer to the block containing rec */
};
```