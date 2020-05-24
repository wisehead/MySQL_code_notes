#1.INNOBASE_SHARE

```cpp
/** InnoDB table share */
typedef struct st_innobase_share {
    THR_LOCK        lock;       /*!< MySQL lock protecting
                        this structure */
    const char*     table_name; /*!< InnoDB table name */
    uint            use_count;  /*!< reference count,
                        incremented in get_share()
                        and decremented in
                        free_share() */
    void*           table_name_hash;/*!< hash table chain node */
    innodb_idx_translate_t  idx_trans_tbl;  /*!< index translation
                        table between MySQL and
                        Innodb */
} INNOBASE_SHARE;
```