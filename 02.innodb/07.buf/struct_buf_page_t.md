#1.buf_page_t

```cpp
struct buf_page_t{
    /** @name General fields
    None of these bit-fields must be modified without holding
    buf_page_get_mutex() [buf_block_t::mutex or
    buf_pool->zip_mutex], since they can be stored in the same
    machine word.  Some of these fields are additionally protected
    by buf_pool->mutex. */
    /* @{ */

    ib_uint32_t space;      /*!< tablespace id; also protected
                    by buf_pool->mutex. */
    ib_uint32_t offset;     /*!< page number; also protected
                    by buf_pool->mutex. */
    /** count of how manyfold this block is currently bufferfixed */
#ifdef PAGE_ATOMIC_REF_COUNT
    ib_uint32_t buf_fix_count;

    /** type of pending I/O operation; also protected by
    buf_pool->mutex for writes only @see enum buf_io_fix */
    byte        io_fix;

    byte        state;
#else
    unsigned    buf_fix_count:19;

    /** type of pending I/O operation; also protected by
    buf_pool->mutex for writes only @see enum buf_io_fix */
    unsigned    io_fix:2;

    /*!< state of the control block; also protected by buf_pool->mutex.
    State transitions from BUF_BLOCK_READY_FOR_USE to BUF_BLOCK_MEMORY
    need not be protected by buf_page_get_mutex(). @see enum buf_page_state.
    State changes that are relevant to page_hash are additionally protected
    by the appropriate page_hash mutex i.e.: if a page is in page_hash or
    is being added to/removed from page_hash then the corresponding changes
    must also be protected by page_hash mutex. */
    unsigned    state:BUF_PAGE_STATE_BITS;

#endif /* PAGE_ATOMIC_REF_COUNT */

#ifndef UNIV_HOTBACKUP
    unsigned    flush_type:2;   /*!< if this block is currently being
                    flushed to disk, this tells the
                    flush_type.
                    @see buf_flush_t */
    unsigned    buf_pool_index:6;/*!< index number of the buffer pool
                    that this block belongs to */
# if MAX_BUFFER_POOLS > 64
#  error "MAX_BUFFER_POOLS > 64; redefine buf_pool_index:6"
# endif
    /* @} */
#endif /* !UNIV_HOTBACKUP */
    page_zip_des_t  zip;        /*!< compressed page; zip.data
                    (but not the data it points to) is
                    also protected by buf_pool->mutex;
                    state == BUF_BLOCK_ZIP_PAGE and
                    zip.data == NULL means an active
                    buf_pool->watch */
#ifndef UNIV_HOTBACKUP
    buf_page_t* hash;       /*!< node used in chaining to
                    buf_pool->page_hash or
                    buf_pool->zip_hash */
#ifdef UNIV_DEBUG
    ibool       in_page_hash;   /*!< TRUE if in buf_pool->page_hash */
    ibool       in_zip_hash;    /*!< TRUE if in buf_pool->zip_hash */
#endif /* UNIV_DEBUG */

    /** @name Page flushing fields
    All these are protected by buf_pool->mutex. */
    /* @{ */

    UT_LIST_NODE_T(buf_page_t) list;
                    /*!< based on state, this is a
                    list node, protected either by
                    buf_pool->mutex or by
                    buf_pool->flush_list_mutex,
                    in one of the following lists in
                    buf_pool:

                    - BUF_BLOCK_NOT_USED:   free
                    - BUF_BLOCK_FILE_PAGE:  flush_list
                    - BUF_BLOCK_ZIP_DIRTY:  flush_list
                    - BUF_BLOCK_ZIP_PAGE:   zip_clean

                    If bpage is part of flush_list
                    then the node pointers are
                    covered by buf_pool->flush_list_mutex.
                    Otherwise these pointers are
                    protected by buf_pool->mutex.

                    The contents of the list node
                    is undefined if !in_flush_list
                    && state == BUF_BLOCK_FILE_PAGE,
                    or if state is one of
                    BUF_BLOCK_MEMORY,
                    BUF_BLOCK_REMOVE_HASH or
                    BUF_BLOCK_READY_IN_USE. */

#ifdef UNIV_DEBUG
    ibool       in_flush_list;  /*!< TRUE if in buf_pool->flush_list;
                    when buf_pool->flush_list_mutex is
                    free, the following should hold:
                    in_flush_list
                    == (state == BUF_BLOCK_FILE_PAGE
                        || state == BUF_BLOCK_ZIP_DIRTY)
                    Writes to this field must be
                    covered by both block->mutex
                    and buf_pool->flush_list_mutex. Hence
                    reads can happen while holding
                    any one of the two mutexes */
    ibool       in_free_list;   /*!< TRUE if in buf_pool->free; when
                    buf_pool->mutex is free, the following
                    should hold: in_free_list
                    == (state == BUF_BLOCK_NOT_USED) */
#endif /* UNIV_DEBUG */
    lsn_t       newest_modification;
                    /*!< log sequence number of
                    the youngest modification to
                    this block, zero if not
                    modified. Protected by block
                    mutex */
    lsn_t       oldest_modification;
                    /*!< log sequence number of
                    the START of the log entry
                    written of the oldest
                    modification to this block
                    which has not yet been flushed
                    on disk; zero if all
                    modifications are on disk.
                    Writes to this field must be
                    covered by both block->mutex
                    and buf_pool->flush_list_mutex. Hence
                    reads can happen while holding
                    any one of the two mutexes */
    /* @} */
    /** @name LRU replacement algorithm fields
    These fields are protected by buf_pool->mutex only (not
    buf_pool->zip_mutex or buf_block_t::mutex). */
    /* @{ */

    UT_LIST_NODE_T(buf_page_t) LRU;
                    /*!< node of the LRU list */
#ifdef UNIV_DEBUG
    ibool       in_LRU_list;    /*!< TRUE if the page is in
                    the LRU list; used in
                    debugging */
#endif /* UNIV_DEBUG */
    unsigned    old:1;      /*!< TRUE if the block is in the old
                    blocks in buf_pool->LRU_old */
    unsigned    freed_page_clock:31;/*!< the value of
                    buf_pool->freed_page_clock
                    when this block was the last
                    time put to the head of the
                    LRU list; a thread is allowed
                    to read this for heuristic
                    purposes without holding any
                    mutex or latch */
    /* @} */
    unsigned    access_time;    /*!< time of first access, or
                    0 if the block was never accessed
                    in the buffer pool. Protected by
                    block mutex */
# if defined UNIV_DEBUG_FILE_ACCESSES || defined UNIV_DEBUG
    ibool       file_page_was_freed;
                    /*!< this is set to TRUE when
                    fsp frees a page in buffer pool;
                    protected by buf_pool->zip_mutex
                    or buf_block_t::mutex. */
# endif /* UNIV_DEBUG_FILE_ACCESSES || UNIV_DEBUG */
#endif /* !UNIV_HOTBACKUP */
};            
```