#1.btr_search_sys_t

```cpp
/** The hash index system */
struct btr_search_sys_t{
    hash_table_t*   hash_index; /*!< the adaptive hash index,
                    mapping dtuple_fold values
                    to rec_t pointers on index pages */
};

/** The adaptive hash index */
extern btr_search_sys_t*    btr_search_sys;
```