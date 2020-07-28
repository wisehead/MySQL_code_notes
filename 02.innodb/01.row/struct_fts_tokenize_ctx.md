#1.struct fts_tokenize_ctx

```cpp
/** Structure stores information from string tokenization operation */
struct fts_tokenize_ctx {
  ulint processed_len{0}; /*!< processed string length */
  ulint init_pos{0};      /*!< doc start position */
  ulint buf_used{0};      /*!< the sort buffer (ID) when
                               tokenization stops, which
                               could due to sort buffer full */
  ulint rows_added[FTS_NUM_AUX_INDEX]{0};
  /*!< number of rows added for
  each FTS index partition */
  ib_rbt_t *cached_stopword{nullptr}; /*!< in: stopword list */
  dfield_t sort_field[FTS_NUM_FIELDS_SORT];
  /*!< in: sort field */
  fts_token_list_t fts_token_list;
};

typedef struct fts_tokenize_ctx fts_tokenize_ctx_t;
```