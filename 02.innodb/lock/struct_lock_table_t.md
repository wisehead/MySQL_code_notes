#1.struct lock_table_t

```cpp
/** A table lock */
struct lock_table_t {
    dict_table_t*   table;      /*!< database table in dictionary
                    cache */
    UT_LIST_NODE_T(lock_t)
            locks;      /*!< list of locks on the same
                    table */
};
```