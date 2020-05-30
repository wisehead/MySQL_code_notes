#1.struct dict_sys_t

```cpp
/* Dictionary system struct */
struct dict_sys_t{
    ib_mutex_t      mutex;      /*!< mutex protecting the data
                    dictionary; protects also the
                    disk-based dictionary system tables;
                    this mutex serializes CREATE TABLE
                    and DROP TABLE, as well as reading
                    the dictionary data for a table from
                    system tables */
    row_id_t    row_id;     /*!< the next row id to assign;
                    NOTE that at a checkpoint this
                    must be written to the dict system
                    header and flushed to a file; in
                    recovery this must be derived from
                    the log records */
    hash_table_t*   table_hash; /*!< hash table of the tables, based
                    on name */
    hash_table_t*   table_id_hash;  /*!< hash table of the tables, based
                    on id */
    ulint       size;       /*!< varying space in bytes occupied
                    by the data dictionary table and
                    index objects */
    dict_table_t*   sys_tables; /*!< SYS_TABLES table */
    dict_table_t*   sys_columns;    /*!< SYS_COLUMNS table */
    dict_table_t*   sys_indexes;    /*!< SYS_INDEXES table */
    dict_table_t*   sys_fields; /*!< SYS_FIELDS table */

    /*=============================*/
    UT_LIST_BASE_NODE_T(dict_table_t)
            table_LRU;  /*!< List of tables that can be evicted
                    from the cache */
    UT_LIST_BASE_NODE_T(dict_table_t)
            table_non_LRU;  /*!< List of tables that can't be
                    evicted from the cache */
};
```