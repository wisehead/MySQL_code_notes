#1.struct fts_cache_t

```cpp
/** The cache for the FTS system. It is a memory-based inverted index
that new entries are added to, until it grows over the configured maximum
size, at which time its contents are written to the INDEX table. */
struct fts_cache_t {
#ifndef UNIV_HOTBACKUP
  rw_lock_t lock; /*!< lock protecting all access to the
                  memory buffer. FIXME: this needs to
                  be our new upgrade-capable rw-lock */

  rw_lock_t init_lock; /*!< lock used for the cache
                       intialization, it has different
                       SYNC level as above cache lock */
#endif                 /* !UNIV_HOTBACKUP */

  ib_mutex_t optimize_lock; /*!< Lock for OPTIMIZE */

  ib_mutex_t deleted_lock; /*!< Lock covering deleted_doc_ids */

  ib_mutex_t doc_id_lock; /*!< Lock covering Doc ID */

  ib_vector_t *deleted_doc_ids; /*!< Array of deleted doc ids, each
                                element is of type fts_update_t */

  ib_vector_t *indexes; /*!< We store the stats and inverted
                        index for the individual FTS indexes
                        in this vector. Each element is
                        an instance of fts_index_cache_t */

  ib_vector_t *get_docs; /*!< information required to read
                         the document from the table. Each
                         element is of type fts_doc_t */

  ulint total_size;      /*!< total size consumed by the ilist
                         field of all nodes. SYNC is run
                         whenever this gets too big */
  fts_sync_t *sync;      /*!< sync structure to sync data to
                         disk */
  ib_alloc_t *sync_heap; /*!< The heap allocator, for indexes
                         and deleted_doc_ids, ie. transient
                         objects, they are recreated after
                         a SYNC is completed */

  ib_alloc_t *self_heap; /*!< This heap is the heap out of
                         which an instance of the cache itself
                         was created. Objects created using
                         this heap will last for the lifetime
                         of the cache */

  doc_id_t next_doc_id; /*!< Next doc id */

  doc_id_t synced_doc_id; /*!< Doc ID sync-ed to CONFIG table */

  doc_id_t first_doc_id; /*!< first doc id since this table
                         was opened */

  ulint deleted; /*!< Number of doc ids deleted since
                 last optimized. This variable is
                 covered by deleted_lock */

  ulint added; /*!< Number of doc ids added since last
               optimized. This variable is covered by
               the deleted lock */

  fts_stopword_t stopword_info; /*!< Cached stopwords for the FTS */
  mem_heap_t *cache_heap;       /*!< Cache Heap */
};                         

```