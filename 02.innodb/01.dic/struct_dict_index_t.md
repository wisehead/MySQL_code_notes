#1.dict_index_t

```cpp
/** Data structure for an index.  Most fields will be
initialized to 0, NULL or FALSE in dict_mem_index_create(). */
struct dict_index_t{
    index_id_t  id; /*!< id of the index */
    mem_heap_t* heap;   /*!< memory heap */
    const char* name;   /*!< index name */
    const char* table_name;/*!< table name */
    dict_table_t*   table;  /*!< back pointer to table */
#ifndef UNIV_HOTBACKUP
    unsigned    space:32;
                /*!< space where the index tree is placed */
    unsigned    page:32;/*!< index tree root page number */
#endif /* !UNIV_HOTBACKUP */
    unsigned    type:DICT_IT_BITS;
                /*!< index type (DICT_CLUSTERED, DICT_UNIQUE,
                DICT_UNIVERSAL, DICT_IBUF, DICT_CORRUPT) */
#define MAX_KEY_LENGTH_BITS 12
    unsigned    trx_id_offset:MAX_KEY_LENGTH_BITS;
                /*!< position of the trx id column
                in a clustered index record, if the fields
                before it are known to be of a fixed size,
                0 otherwise */
#if (1<<MAX_KEY_LENGTH_BITS) < MAX_KEY_LENGTH
# error (1<<MAX_KEY_LENGTH_BITS) < MAX_KEY_LENGTH
#endif
    unsigned    n_user_defined_cols:10;
                /*!< number of columns the user defined to
                be in the index: in the internal
                representation we add more columns */
    unsigned    n_uniq:10;/*!< number of fields from the beginning
                which are enough to determine an index
                entry uniquely */
    unsigned    n_def:10;/*!< number of fields defined so far */
    unsigned    n_fields:10;/*!< number of fields in the index */
    unsigned    n_nullable:10;/*!< number of nullable fields */
    unsigned    cached:1;/*!< TRUE if the index object is in the
                dictionary cache */
    unsigned    to_be_dropped:1;
                /*!< TRUE if the index is to be dropped;
                protected by dict_operation_lock */
    unsigned    online_status:2;
                /*!< enum online_index_status.
                Transitions from ONLINE_INDEX_COMPLETE (to
                ONLINE_INDEX_CREATION) are protected
                by dict_operation_lock and
                dict_sys->mutex. Other changes are
                protected by index->lock. */
    dict_field_t*   fields; /*!< array of field descriptions */
#ifndef UNIV_HOTBACKUP
    UT_LIST_NODE_T(dict_index_t)
            indexes;/*!< list of indexes of the table */
    btr_search_t*   search_info;
                /*!< info used in optimistic searches */
    row_log_t*  online_log;
                /*!< the log of modifications
                during online index creation;
                valid when online_status is
                ONLINE_INDEX_CREATION */
    /*----------------------*/
    /** Statistics for query optimization */
    /* @{ */
    ib_uint64_t*    stat_n_diff_key_vals;
                /*!< approximate number of different
                key values for this index, for each
                n-column prefix where 1 <= n <=
                dict_get_n_unique(index) (the array is
                indexed from 0 to n_uniq-1); we
                periodically calculate new
                estimates */
    ib_uint64_t*    stat_n_sample_sizes;
                /*!< number of pages that were sampled
                to calculate each of stat_n_diff_key_vals[],
                e.g. stat_n_sample_sizes[3] pages were sampled
                to get the number stat_n_diff_key_vals[3]. */
    ib_uint64_t*    stat_n_non_null_key_vals;
                /* approximate number of non-null key values
                for this index, for each column where
                1 <= n <= dict_get_n_unique(index) (the array
                is indexed from 0 to n_uniq-1); This
                is used when innodb_stats_method is
                "nulls_ignored". */
    ulint       stat_index_size;
                /*!< approximate index size in
                database pages */
    ulint       stat_n_leaf_pages;
                /*!< approximate number of leaf pages in the
                index tree */
    /** Statistics for defragmentation, these numbers are estimations and
    could be very inaccurate at certain times, e.g. right after restart,
    during defragmentation, etc. */
    /* @{ */
    ulint       stat_defrag_modified_counter;
    ulint       stat_defrag_n_pages_freed;
                /* number of pages freed by defragmentation. */
    ulint       stat_defrag_n_page_split;
                /* number of page splits since last full index
                defragmentation. */
    ulint       stat_defrag_data_size_sample[STAT_DEFRAG_DATA_SIZE_N_SAMPLE];
                /* data size when compression failure happened
                the most recent 10 times. */
    ulint       stat_defrag_sample_next_slot;
                /* in which slot the next sample should be
                saved. */
    /* @} */
    rw_lock_t   lock;   /*!< read-write lock protecting the
                upper levels of the index tree */
    trx_id_t    trx_id; /*!< id of the transaction that created this
                index, or 0 if the index existed
                when InnoDB was started up */
    zip_pad_info_t  zip_pad;/*!< Information about state of
                compression failures and successes */
        uint        max_rec_size; /* the max rec length of the index,
                                 if the space left on the zip page
                                 is less than it, send the page
                                 to asynchronous compress thread */
#endif /* !UNIV_HOTBACKUP */
#ifdef UNIV_BLOB_DEBUG
    ib_mutex_t      blobs_mutex;
                /*!< mutex protecting blobs */
    ib_rbt_t*   blobs;  /*!< map of (page_no,heap_no,field_no)
                to first_blob_page_no; protected by
                blobs_mutex; @see btr_blob_dbg_t */
#endif /* UNIV_BLOB_DEBUG */
#ifdef UNIV_DEBUG
    ulint       magic_n;/*!< magic number */
/** Value of dict_index_t::magic_n */
# define DICT_INDEX_MAGIC_N 76789786
#endif
};                    
```