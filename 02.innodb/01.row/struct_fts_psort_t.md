#1.struct fts_psort_t

```cpp
struct fts_psort_t {
  ulint psort_id; /*!< Parallel sort ID */
  row_merge_buf_t *merge_buf[FTS_NUM_AUX_INDEX];
  /*!< sort buffer */
  merge_file_t *merge_file[FTS_NUM_AUX_INDEX];
  /*!< sort file */
  row_merge_block_t *merge_block[FTS_NUM_AUX_INDEX];
  /*!< buffer to write to file */
  row_merge_block_t *block_alloc[FTS_NUM_AUX_INDEX];
  /*!< buffer to allocated */
  ulint child_status;               /*!< child thread status */
  ulint state;                      /*!< parent thread state */
  fts_doc_list_t fts_doc_list;      /*!< doc list to process */
  fts_psort_common_t *psort_common; /*!< ptr to all psort info */
  dberr_t error;                    /*!< db error during psort */
  ulint memory_used;                /*!< memory used by fts_doc_list */
  ib_mutex_t mutex;                 /*!< mutex for fts_doc_list */
};

```