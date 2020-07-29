#1.struct fts_index_cache_t

```cpp
/** Since we can have multiple FTS indexes on a table, we keep a
per index cache of words etc. */
struct fts_index_cache_t {
  dict_index_t *index; /*!< The FTS index instance */

  ib_rbt_t *words; /*!< Nodes; indexed by fts_string_t*,
                   cells are fts_tokenizer_word_t*.*/

  ib_vector_t *doc_stats; /*!< Array of the fts_doc_stats_t
                          contained in the memory buffer.
                          Must be in sorted order (ascending).
                          The  ideal choice is an rb tree but
                          the rb tree imposes a space overhead
                          that we can do without */

  que_t **ins_graph; /*!< Insert query graphs */

  que_t **sel_graph;     /*!< Select query graphs */
  CHARSET_INFO *charset; /*!< charset */
};
```
