#1.struct row_merge_buf_t

```cpp
/** Buffer for sorting in main memory. */
struct row_merge_buf_t {
  mem_heap_t *heap;     /*!< memory heap where allocated */
  dict_index_t *index;  /*!< the index the tuples belong to */
  ulint total_size;     /*!< total amount of data bytes */
  ulint n_tuples;       /*!< number of data tuples */
  ulint max_tuples;     /*!< maximum number of data tuples */
  mtuple_t *tuples;     /*!< array of data tuples */
  mtuple_t *tmp_tuples; /*!< temporary copy of tuples,
                        for sorting */
};
```