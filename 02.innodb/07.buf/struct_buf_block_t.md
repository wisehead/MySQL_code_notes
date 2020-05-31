#1.buf_block_t

```cpp
/** The buffer control block structure */

struct buf_block_t{

    /** @name General fields */
    /* @{ */

    buf_page_t  page;       /*!< page information; this must
                    be the first field, so that
                    buf_pool->page_hash can point
                    to buf_page_t or buf_block_t */
    byte*       frame;      /*!< pointer to buffer frame which
                    is of size UNIV_PAGE_SIZE, and
                    aligned to an address divisible by
                    UNIV_PAGE_SIZE */
#ifndef UNIV_HOTBACKUP
    UT_LIST_NODE_T(buf_block_t) unzip_LRU;
                    /*!< node of the decompressed LRU list;
                    a block is in the unzip_LRU list
                    if page.state == BUF_BLOCK_FILE_PAGE
                    and page.zip.data != NULL */
#ifdef UNIV_DEBUG
    ibool       in_unzip_LRU_list;/*!< TRUE if the page is in the
                    decompressed LRU list;
                    used in debugging */
#endif /* UNIV_DEBUG */
    ib_mutex_t  mutex;      /*!< mutex protecting this block:
                    state (also protected by the buffer
                    pool mutex), io_fix, buf_fix_count,
                    and accessed; we introduce this new
                    mutex in InnoDB-5.1 to relieve
                    contention on the buffer pool mutex */
    rw_lock_t   lock;       /*!< read-write lock of the buffer
                    frame */
    unsigned    lock_hash_val:32;/*!< hashed value of the page address
                    in the record lock hash table;
                    protected by buf_block_t::lock
                    (or buf_block_t::mutex, buf_pool->mutex
                        in buf_page_get_gen(),
                    buf_page_init_for_read()
                    and buf_page_create()) */
    ibool       check_index_page_at_flush;
                    /*!< TRUE if we know that this is
                    an index page, and want the database
                    to check its consistency before flush;
                    note that there may be pages in the
                    buffer pool which are index pages,
                    but this flag is not set because
                    we do not keep track of all pages;
                    NOT protected by any mutex */
    /* @} */
    /** @name Optimistic search field */
    /* @{ */

    ib_uint64_t modify_clock;   /*!< this clock is incremented every
                    time a pointer to a record on the
                    page may become obsolete; this is
                    used in the optimistic cursor
                    positioning: if the modify clock has
                    not changed, we know that the pointer
                    is still valid; this field may be
                    changed if the thread (1) owns the
                    pool mutex and the page is not
                    bufferfixed, or (2) the thread has an
                    x-latch on the block */
    /* @} */
    /** @name Hash search fields (unprotected)
    NOTE that these fields are NOT protected by any semaphore! */
    /* @{ */

    ulint       n_hash_helps;   /*!< counter which controls building
                    of a new hash index for the page */
    ulint       n_fields;   /*!< recommended prefix length for hash
                    search: number of full fields */
    ulint       n_bytes;    /*!< recommended prefix: number of bytes
                    in an incomplete field */
    ibool       left_side;  /*!< TRUE or FALSE, depending on
                    whether the leftmost record of several
                    records with the same prefix should be
                    indexed in the hash index */
    /* @} */

    /** @name Hash search fields
    These 5 fields may only be modified when we have
    an x-latch on btr_search_latch AND
    - we are holding an s-latch or x-latch on buf_block_t::lock or
    - we know that buf_block_t::buf_fix_count == 0.

    An exception to this is when we init or create a page
    in the buffer pool in buf0buf.cc.

    Another exception is that assigning block->index = NULL
    is allowed whenever holding an x-latch on btr_search_latch. */

    /* @{ */

#if defined UNIV_AHI_DEBUG || defined UNIV_DEBUG
    ulint       n_pointers; /*!< used in debugging: the number of
                    pointers in the adaptive hash index
                    pointing to this frame */
#endif /* UNIV_AHI_DEBUG || UNIV_DEBUG */
    unsigned    curr_n_fields:10;/*!< prefix length for hash indexing:
                    number of full fields */
    unsigned    curr_n_bytes:15;/*!< number of bytes in hash
                    indexing */
    unsigned    curr_left_side:1;/*!< TRUE or FALSE in hash indexing */
    dict_index_t*   index;      /*!< Index for which the
                    adaptive hash index has been
                    created, or NULL if the page
                    does not exist in the
                    index. Note that it does not
                    guarantee that the index is
                    complete, though: there may
                    have been hash collisions,
                    record deletions, etc. */
    /* @} */
# ifdef UNIV_SYNC_DEBUG
    /** @name Debug fields */
    /* @{ */
    rw_lock_t   debug_latch;    /*!< in the debug version, each thread
                    which bufferfixes the block acquires
                    an s-latch here; so we can use the
                    debug utilities in sync0rw */
    /* @} */
# endif
#endif /* !UNIV_HOTBACKUP */
};        
```