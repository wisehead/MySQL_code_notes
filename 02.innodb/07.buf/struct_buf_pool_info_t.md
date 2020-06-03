#1.struct buf_pool_info_t

```cpp
/** This structure defines information we will fetch from each buffer pool. It
will be used to print table IO stats */
struct buf_pool_info_t{
    /* General buffer pool info */
    ulint   pool_unique_id;     /*!< Buffer Pool ID */
    ulint   pool_size;      /*!< Buffer Pool size in pages */
    ulint   lru_len;        /*!< Length of buf_pool->LRU */
    ulint   old_lru_len;        /*!< buf_pool->LRU_old_len */
    ulint   free_list_len;      /*!< Length of buf_pool->free list */
    ulint   flush_list_len;     /*!< Length of buf_pool->flush_list */
    ulint   n_pend_unzip;       /*!< buf_pool->n_pend_unzip, pages
                    pending decompress */
    ulint   n_pend_reads;       /*!< buf_pool->n_pend_reads, pages
                    pending read */
    ulint   n_pending_flush_lru;    /*!< Pages pending flush in LRU */
    ulint   n_pending_flush_single_page;/*!< Pages pending to be
                    flushed as part of single page
                    flushes issued by various user
                    threads */
    ulint   n_pending_flush_list;   /*!< Pages pending flush in FLUSH
                    LIST */
    ulint   n_pages_made_young; /*!< number of pages made young */
    ulint   n_pages_not_made_young; /*!< number of pages not made young */
    ulint   n_pages_read;       /*!< buf_pool->n_pages_read */
    ulint   n_pages_created;    /*!< buf_pool->n_pages_created */
    ulint   n_pages_written;    /*!< buf_pool->n_pages_written */
    ulint   n_page_gets;        /*!< buf_pool->n_page_gets */
    ulint   n_ra_pages_read_rnd;    /*!< buf_pool->n_ra_pages_read_rnd,
                    number of pages readahead */
    ulint   n_ra_pages_read;    /*!< buf_pool->n_ra_pages_read, number
                    of pages readahead */
    ulint   n_ra_pages_evicted; /*!< buf_pool->n_ra_pages_evicted,
                    number of readahead pages evicted
                    without access */
    ulint   n_page_get_delta;   /*!< num of buffer pool page gets since
                    last printout */
                   
    /* Buffer pool access stats */
    double  page_made_young_rate;   /*!< page made young rate in pages
                    per second */
    double  page_not_made_young_rate;/*!< page not made young rate
                    in pages per second */
    double  pages_read_rate;    /*!< num of pages read per second */
    double  pages_created_rate; /*!< num of pages create per second */
    double  pages_written_rate; /*!< num of  pages written per second */
    ulint   page_read_delta;    /*!< num of pages read since last
                    printout */
    ulint   young_making_delta; /*!< num of pages made young since
                    last printout */
    ulint   not_young_making_delta; /*!< num of pages not make young since
                    last printout */
                   
    /* Statistics about read ahead algorithm.  */
    double  pages_readahead_rnd_rate;/*!< random readahead rate in pages per
                    second */
    double  pages_readahead_rate;   /*!< readahead rate in pages per
                    second */
    double  pages_evicted_rate; /*!< rate of readahead page evicted
                    without access, in pages per second */
                   
    /* Stats about LRU eviction */
    ulint   unzip_lru_len;      /*!< length of buf_pool->unzip_LRU 
                    list */
    /* Counters for LRU policy */
    ulint   io_sum;         /*!< buf_LRU_stat_sum.io */
    ulint   io_cur;         /*!< buf_LRU_stat_cur.io, num of IO
                    for current interval */
    ulint   unzip_sum;      /*!< buf_LRU_stat_sum.unzip */
    ulint   unzip_cur;      /*!< buf_LRU_stat_cur.unzip, num
                    pages decompressed in current
                    interval */
};     
```