#1.struct row_fts_token_t

```cpp
/** Row fts token for plugin parser */
struct row_fts_token_t {
  fts_string_t *text; /*!< token */
  ulint position;     /*!< token position in the document */
  UT_LIST_NODE_T(row_fts_token_t)
  token_list; /*!< next token link */
};

```