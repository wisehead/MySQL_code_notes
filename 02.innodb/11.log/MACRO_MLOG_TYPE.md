#1.MACRO MLOG_TYPE

```cpp
/** @name Log item types
The log items are declared 'byte' so that the compiler can warn if val
and type parameters are switched in a call to mlog_write_ulint. NOTE!
For 1 - 8 bytes, the flag value must give the length also! @{ */
#define MLOG_SINGLE_REC_FLAG    128     /*!< if the mtr contains only
                        one log record for one page,
                        i.e., write_initial_log_record
                        has been called only once,
                        this flag is ORed to the type
                        of that first log record */
#define MLOG_1BYTE      (1)     /*!< one byte is written */
#define MLOG_2BYTES     (2)     /*!< 2 bytes ... */
#define MLOG_4BYTES     (4)     /*!< 4 bytes ... */
#define MLOG_8BYTES     (8)     /*!< 8 bytes ... */
#define MLOG_REC_INSERT     ((byte)9)   /*!< record insert */
#define MLOG_REC_CLUST_DELETE_MARK ((byte)10)   /*!< mark clustered index record
                        deleted */
#define MLOG_REC_SEC_DELETE_MARK ((byte)11) /*!< mark secondary index record
                        deleted */
#define MLOG_REC_UPDATE_IN_PLACE ((byte)13) /*!< update of a record,
                        preserves record field sizes */
#define MLOG_REC_DELETE     ((byte)14)  /*!< delete a record from a
                        page */
#define MLOG_LIST_END_DELETE    ((byte)15)  /*!< delete record list end on
                        index page */
#define MLOG_LIST_START_DELETE  ((byte)16)  /*!< delete record list start on
                        index page */
#define MLOG_LIST_END_COPY_CREATED ((byte)17)   /*!< copy record list end to a
                        new created index page */
#define MLOG_PAGE_REORGANIZE    ((byte)18)  /*!< reorganize an
                        index page in
                        ROW_FORMAT=REDUNDANT */
#define MLOG_PAGE_CREATE    ((byte)19)  /*!< create an index page */
#define MLOG_UNDO_INSERT    ((byte)20)  /*!< insert entry in an undo
                        log */
#define MLOG_UNDO_ERASE_END ((byte)21)  /*!< erase an undo log
                        page end */
#define MLOG_UNDO_INIT      ((byte)22)  /*!< initialize a page in an
                        undo log */
#define MLOG_UNDO_HDR_DISCARD   ((byte)23)  /*!< discard an update undo log
                        header */
#define MLOG_UNDO_HDR_REUSE ((byte)24)  /*!< reuse an insert undo log
                        header */
#define MLOG_UNDO_HDR_CREATE    ((byte)25)  /*!< create an undo
                        log header */
#define MLOG_REC_MIN_MARK   ((byte)26)  /*!< mark an index
                        record as the
                        predefined minimum
                        record */
#define MLOG_IBUF_BITMAP_INIT   ((byte)27)  /*!< initialize an
                        ibuf bitmap page */
/*#define   MLOG_FULL_PAGE  ((byte)28)  full contents of a page */
#ifdef UNIV_LOG_LSN_DEBUG
# define MLOG_LSN       ((byte)28)  /* current LSN */
#endif
#define MLOG_INIT_FILE_PAGE ((byte)29)  /*!< this means that a
                        file page is taken
                        into use and the prior
                        contents of the page
                        should be ignored: in
                        recovery we must not
                        trust the lsn values
                        stored to the file
                        page */
#define MLOG_WRITE_STRING   ((byte)30)  /*!< write a string to
                        a page */
#define MLOG_MULTI_REC_END  ((byte)31)  /*!< if a single mtr writes
                        several log records,
                        this log record ends the
                        sequence of these records */
#define MLOG_DUMMY_RECORD   ((byte)32)  /*!< dummy log record used to
                        pad a log block full */
#define MLOG_FILE_CREATE    ((byte)33)  /*!< log record about an .ibd
                        file creation */
#define MLOG_FILE_RENAME    ((byte)34)  /*!< log record about an .ibd
                        file rename */
#define MLOG_FILE_DELETE    ((byte)35)  /*!< log record about an .ibd
                        file deletion */
#define MLOG_COMP_REC_MIN_MARK  ((byte)36)  /*!< mark a compact
                        index record as the
                        predefined minimum
                        record */
#define MLOG_COMP_PAGE_CREATE   ((byte)37)  /*!< create a compact
                        index page */
#define MLOG_COMP_REC_INSERT    ((byte)38)  /*!< compact record insert */
#define MLOG_COMP_REC_CLUST_DELETE_MARK ((byte)39)
                        /*!< mark compact
                        clustered index record
                        deleted */
#define MLOG_COMP_REC_SEC_DELETE_MARK ((byte)40)/*!< mark compact
                        secondary index record
                        deleted; this log
                        record type is
                        redundant, as
                        MLOG_REC_SEC_DELETE_MARK
                        is independent of the
                        record format. */
#define MLOG_COMP_REC_UPDATE_IN_PLACE ((byte)41)/*!< update of a
                        compact record,
                        preserves record field
                        sizes */
#define MLOG_COMP_REC_DELETE    ((byte)42)  /*!< delete a compact record
                        from a page */
#define MLOG_COMP_LIST_END_DELETE ((byte)43)    /*!< delete compact record list
                        end on index page */
#define MLOG_COMP_LIST_START_DELETE ((byte)44)  /*!< delete compact record list
                        start on index page */
#define MLOG_COMP_LIST_END_COPY_CREATED ((byte)45)
                        /*!< copy compact
                        record list end to a
                        new created index
                        page */
#define MLOG_COMP_PAGE_REORGANIZE ((byte)46)    /*!< reorganize an index page */
#define MLOG_FILE_CREATE2   ((byte)47)  /*!< log record about creating
                        an .ibd file, with format */
#define MLOG_ZIP_WRITE_NODE_PTR ((byte)48)  /*!< write the node pointer of
                        a record on a compressed
                        non-leaf B-tree page */
#define MLOG_ZIP_WRITE_BLOB_PTR ((byte)49)  /*!< write the BLOB pointer
                        of an externally stored column
                        on a compressed page */
#define MLOG_ZIP_WRITE_HEADER   ((byte)50)  /*!< write to compressed page
                        header */
#define MLOG_ZIP_PAGE_COMPRESS  ((byte)51)  /*!< compress an index page */
#define MLOG_ZIP_PAGE_COMPRESS_NO_DATA  ((byte)52)/*!< compress an index page
                        without logging it's image */
#define MLOG_ZIP_PAGE_REORGANIZE ((byte)53) /*!< reorganize a compressed
                        page */
#define MLOG_TEST   ((byte)54)  /** Used in tests of redo log. It must never be used outside unit tests. */
#define MLOG_BIGGEST_TYPE   ((byte)55)  /*!< biggest value (used in
assertions) */
/* @} */
```