#1.struct hash_table_t

```cpp
/* The hash table structure */
struct hash_table_t {
    enum hash_table_sync_t  type;   /*<! type of hash_table. */
#if defined UNIV_AHI_DEBUG || defined UNIV_DEBUG
# ifndef UNIV_HOTBACKUP
    ibool           adaptive;/* TRUE if this is the hash
                    table of the adaptive hash
                    index */
# endif /* !UNIV_HOTBACKUP */
#endif /* UNIV_AHI_DEBUG || UNIV_DEBUG */
    ulint           n_cells;/* number of cells in the hash table */
    hash_cell_t*        array;  /*!< pointer to cell array */
#ifndef UNIV_HOTBACKUP
    ulint           n_sync_obj;/* if sync_objs != NULL, then
                    the number of either the number
                    of mutexes or the number of
                    rw_locks depending on the type.
                    Must be a power of 2 */
    union {
        ib_mutex_t* mutexes;/* NULL, or an array of mutexes
                    used to protect segments of the
                    hash table */
        rw_lock_t*  rw_locks;/* NULL, or an array of rw_lcoks
                    used to protect segments of the
                    hash table */
    } sync_obj;

    mem_heap_t**        heaps;  /*!< if this is non-NULL, hash
                    chain nodes for external chaining
                    can be allocated from these memory
                    heaps; there are then n_mutexes
                    many of these heaps */
#endif /* !UNIV_HOTBACKUP */
    mem_heap_t*     heap;
#ifdef UNIV_DEBUG
    ulint           magic_n;
# define HASH_TABLE_MAGIC_N 76561114
#endif /* UNIV_DEBUG */
};
```