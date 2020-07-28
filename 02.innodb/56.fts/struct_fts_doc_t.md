#1.struct fts_doc_t

```cpp
/** This type represents a single document. */
struct fts_doc_t {
  fts_string_t text; /*!< document text */

  ibool found; /*!< TRUE if the document was found
               successfully in the database */

  ib_rbt_t *tokens; /*!< This is filled when the document
                    is tokenized. Tokens; indexed by
                    fts_string_t*, cells are of type
                    fts_token_t* */

  ib_alloc_t *self_heap; /*!< An instance of this type is
                         allocated from this heap along
                         with any objects that have the
                         same lifespan, most notably
                         the vector of token positions */
  CHARSET_INFO *charset; /*!< Document's charset info */

  st_mysql_ftparser *parser; /*!< fts plugin parser */

  bool is_ngram; /*!< Whether it is a ngram parser */

  ib_rbt_t *stopwords; /*!< Stopwords */
};
```