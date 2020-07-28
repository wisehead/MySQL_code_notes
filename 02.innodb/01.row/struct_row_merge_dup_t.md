#1.struct row_merge_dup_t

```cpp
/** Structure for reporting duplicate records. */
struct row_merge_dup_t {
  dict_index_t *index;  /*!< index being sorted */
  struct TABLE *table;  /*!< MySQL table object */
  const ulint *col_map; /*!< mapping of column numbers
                        in table to the rebuilt table
                        (index->table), or NULL if not
                        rebuilding table */
  ulint n_dup;          /*!< number of duplicates */
};
```