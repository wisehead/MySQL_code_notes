#1.enum buf_page_state

```cpp
/** @brief States of a control block
@see buf_page_t
          
The enumeration values must be 0..7. */
enum buf_page_state {                                                                                                                                                                                                                                           
    BUF_BLOCK_POOL_WATCH,       /*!< a sentinel for the buffer pool
                    watch, element of buf_pool->watch[] */
    BUF_BLOCK_ZIP_PAGE,     /*!< contains a clean
                    compressed page */
    BUF_BLOCK_ZIP_DIRTY,        /*!< contains a compressed
                    page that is in the
                    buf_pool->flush_list */
          
    BUF_BLOCK_NOT_USED,     /*!< is in the free list;
                    must be after the BUF_BLOCK_ZIP_
                    constants for compressed-only pages
                    @see buf_block_state_valid() */
    BUF_BLOCK_READY_FOR_USE,    /*!< when buf_LRU_get_free_block
                    returns a block, it is in this state */
    BUF_BLOCK_FILE_PAGE,        /*!< contains a buffered file page */
    BUF_BLOCK_MEMORY,       /*!< contains some main memory
                    object */
    BUF_BLOCK_REMOVE_HASH       /*!< hash index should be removed
                    before putting to the free list */
};    
```