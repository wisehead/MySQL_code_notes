#1.struct fts_psort_common_t

```cpp
/** Common info passed to each parallel sort thread */
struct fts_psort_common_t {
  row_merge_dup_t *dup;    /*!< descriptor of FTS index */
  dict_table_t *old_table; /*!< Needed to fetch LOB from
                           old table. */
  dict_table_t *new_table; /*!< source table */
  trx_t *trx;              /*!< transaction */
  fts_psort_t *all_info;   /*!< all parallel sort info */
  os_event_t sort_event;   /*!< sort event */
  os_event_t merge_event;  /*!< merge event */
  ibool opt_doc_id_size;   /*!< whether to use 4 bytes
                           instead of 8 bytes integer to
                           store Doc ID during sort, if
                           Doc ID will not be big enough
                           to use 8 bytes value */
};
```