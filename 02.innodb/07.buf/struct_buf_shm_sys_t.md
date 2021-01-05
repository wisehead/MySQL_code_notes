#1.struct buf_shm_sys_t

```cpp
/** Shared Buffer Pool Structure */
struct buf_shm_sys_t {
    /** Magic number  */
    ulint       magic_n;

    /** Version number */
    ulint       version;

    /** Shared memory id of shared buffer pool */
    int     shm_id;

    /** Buffer pool state */
    buf_shm_state   state;

    /** Next shared memory key */
    key_t       next_key;

    /** Applied lsn on slave */
    lsn_t       applied_lsn;

    /* Configuration variables */
    /** innodb_buffer_pool_size */
    ulint       buf_pool_size;

    /** innodb_buffer_pool_instances */
    ulint       buf_pool_instances;

    /** innodb_buffer_pool_chunk_size */
    ulint       buf_pool_chunk_unit;

    /** Allocated memory size for chunk */
    ulint       buf_pool_chunk_alloc_size;

    /** Total count of chunks */
    ulint       n_chunks;

    /** Shared memory key array of chunks */
    key_t*      chunk_keys;

    /**!!! End of version 0 !!!*/

#ifndef UNIV_INNOCACHECLEAN
    /** Mutex for shared buffer pool */
    BufPoolMutex    mutex;
#endif /* !UNIV_INNOCACHECLEAN */

    /* Reserve 4k space for extension.
    Note: Do remember to update version after adding new fields. */
};

```