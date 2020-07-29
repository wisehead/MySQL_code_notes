#1.struct fts_node_t

```cpp
/** Columns of the FTS auxiliary INDEX table */
struct fts_node_t {
  doc_id_t first_doc_id; /*!< First document id in ilist. */

  doc_id_t last_doc_id; /*!< Last document id in ilist. */

  byte *ilist; /*!< Binary list of documents & word
               positions the token appears in.
               TODO: For now, these are simply
               ut_malloc'd, but if testing shows
               that they waste memory unacceptably, a
               special memory allocator will have
               to be written */

  ulint doc_count; /*!< Number of doc ids in ilist */

  ulint ilist_size; /*!< Used size of ilist in bytes. */

  ulint ilist_size_alloc;
  /*!< Allocated size of ilist in
  bytes */
  bool synced; /*!< flag whether the node is synced */
};
```