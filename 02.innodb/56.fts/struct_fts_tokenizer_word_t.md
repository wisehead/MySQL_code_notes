#1.struct fts_tokenizer_word_t

```cpp
/** A tokenizer word. Contains information about one word. */
struct fts_tokenizer_word_t {
  fts_string_t text; /*!< Token text. */

  ib_vector_t *nodes; /*!< Word node ilists, each element is
                      of type fts_node_t */
};
```