#1.enum fts_table_type_t

```cpp
/** The FTS table types. */
enum fts_table_type_t {
  FTS_INDEX_TABLE, /*!< FTS auxiliary table that is
                   specific to a particular FTS index
                   on a table */

  FTS_COMMON_TABLE, /*!< FTS auxiliary table that is common
                    for all FTS index on a table */

  FTS_OBSOLETED_TABLE /*!< FTS obsoleted tables like DOC_ID,
                      ADDED, STOPWORDS */
};
```