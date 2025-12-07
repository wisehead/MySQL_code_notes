#1.struct lock_t

```cpp
/** Lock struct; protected by lock_sys->mutex */
struct lock_t {
    trx_t*      trx;        /*!< transaction owning the
                    lock */
    UT_LIST_NODE_T(lock_t)
            trx_locks;  /*!< list of the locks of the
                    transaction */
    ulint       type_mode;  /*!< lock type, mode, LOCK_GAP or
                    LOCK_REC_NOT_GAP,
                    LOCK_INSERT_INTENTION,
                    wait flag, ORed */
    hash_node_t hash;       /*!< hash chain node for a record
                    lock */
    dict_index_t*   index;      /*!< index for a record lock */
    union {
        lock_table_t    tab_lock;/*!< table lock */
        lock_rec_t  rec_lock;/*!< record lock */
    } un_member;            /*!< lock details */
};
```