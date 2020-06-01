#1.Transaction system header

```cpp
/** Transaction system header */
/*------------------------------------------------------------- @{ */
#define TRX_SYS_TRX_ID_STORE    0   /*!< the maximum trx id or trx
                    number modulo
                    TRX_SYS_TRX_ID_UPDATE_MARGIN
                    written to a file page by any
                    transaction; the assignment of
                    transaction ids continues from
                    this number rounded up by
                    TRX_SYS_TRX_ID_UPDATE_MARGIN
                    plus
                    TRX_SYS_TRX_ID_UPDATE_MARGIN
                    when the database is
                    started */
#define TRX_SYS_FSEG_HEADER 8   /*!< segment header for the
                    tablespace segment the trx
                    system is created into */
#define TRX_SYS_RSEGS       (8 + FSEG_HEADER_SIZE)
                    /*!< the start of the array of
                    rollback segment specification
                    slots */
/*------------------------------------------------------------- @} */

/* Max number of rollback segments: the number of segment specification slots
in the transaction system array; rollback segment id must fit in one (signed)
byte, therefore 128; each slot is currently 8 bytes in size. If you want
to raise the level to 256 then you will need to fix some assertions that
impose the 7 bit restriction. e.g., mach_write_to_3() */
#define TRX_SYS_N_RSEGS         128
/* Originally, InnoDB defined TRX_SYS_N_RSEGS as 256 but created only one
rollback segment.  It initialized some arrays with this number of entries.
We must remember this limit in order to keep file compatibility. */
#define TRX_SYS_OLD_N_RSEGS     256

/** Maximum length of MySQL binlog file name, in bytes.
@see trx_sys_mysql_master_log_name
@see trx_sys_mysql_bin_log_name */
#define TRX_SYS_MYSQL_LOG_NAME_LEN  512
/** Contents of TRX_SYS_MYSQL_LOG_MAGIC_N_FLD */
#define TRX_SYS_MYSQL_LOG_MAGIC_N   873422344

#if UNIV_PAGE_SIZE_MIN < 4096
# error "UNIV_PAGE_SIZE_MIN < 4096"
#endif
/** The offset of the MySQL replication info in the trx system header;
this contains the same fields as TRX_SYS_MYSQL_LOG_INFO below */
#define TRX_SYS_MYSQL_MASTER_LOG_INFO   (UNIV_PAGE_SIZE - 2000)

/** The offset of the MySQL binlog offset info in the trx system header */
#define TRX_SYS_MYSQL_LOG_INFO      (UNIV_PAGE_SIZE - 1000)
#define TRX_SYS_MYSQL_LOG_MAGIC_N_FLD   0   /*!< magic number which is
                        TRX_SYS_MYSQL_LOG_MAGIC_N
                        if we have valid data in the
                        MySQL binlog info */
#define TRX_SYS_MYSQL_LOG_OFFSET_HIGH   4   /*!< high 4 bytes of the offset
                        within that file */
#define TRX_SYS_MYSQL_LOG_OFFSET_LOW    8   /*!< low 4 bytes of the offset
                        within that file */
#define TRX_SYS_MYSQL_LOG_NAME      12  /*!< MySQL log file name */

/** Doublewrite buffer */
/* @{ */
/** The offset of the doublewrite buffer header on the trx system header page */
#define TRX_SYS_DOUBLEWRITE     (UNIV_PAGE_SIZE - 200)
/*-------------------------------------------------------------*/
#define TRX_SYS_DOUBLEWRITE_FSEG    0   /*!< fseg header of the fseg
                        containing the doublewrite
                        buffer */
#define TRX_SYS_DOUBLEWRITE_MAGIC   FSEG_HEADER_SIZE
                        /*!< 4-byte magic number which
                        shows if we already have
                        created the doublewrite
                        buffer */
#define TRX_SYS_DOUBLEWRITE_BLOCK1  (4 + FSEG_HEADER_SIZE)
                        /*!< page number of the
                        first page in the first
                        sequence of 64
                        (= FSP_EXTENT_SIZE) consecutive
                        pages in the doublewrite
                        buffer */
#define TRX_SYS_DOUBLEWRITE_BLOCK2  (8 + FSEG_HEADER_SIZE)
                        /*!< page number of the
                        first page in the second
                        sequence of 64 consecutive
                        pages in the doublewrite
                        buffer */
#define TRX_SYS_DOUBLEWRITE_REPEAT  12  /*!< we repeat
                        TRX_SYS_DOUBLEWRITE_MAGIC,
                        TRX_SYS_DOUBLEWRITE_BLOCK1,
                        TRX_SYS_DOUBLEWRITE_BLOCK2
                        so that if the trx sys
                        header is half-written
                        to disk, we still may
                        be able to recover the
                        information */
/** If this is not yet set to TRX_SYS_DOUBLEWRITE_SPACE_ID_STORED_N,
we must reset the doublewrite buffer, because starting from 4.1.x the
space id of a data page is stored into
FIL_PAGE_ARCH_LOG_NO_OR_SPACE_ID. */
#define TRX_SYS_DOUBLEWRITE_SPACE_ID_STORED (24 + FSEG_HEADER_SIZE)

/*-------------------------------------------------------------*/
/** Contents of TRX_SYS_DOUBLEWRITE_MAGIC */
#define TRX_SYS_DOUBLEWRITE_MAGIC_N 536853855
/** Contents of TRX_SYS_DOUBLEWRITE_SPACE_ID_STORED */
#define TRX_SYS_DOUBLEWRITE_SPACE_ID_STORED_N 1783657386

/** Size of the doublewrite block in pages */
#define TRX_SYS_DOUBLEWRITE_BLOCK_SIZE  FSP_EXTENT_SIZE
/* @} */

/** File format tag */
/* @{ */
/** The offset of the file format tag on the trx system header page
(TRX_SYS_PAGE_NO of TRX_SYS_SPACE) */
#define TRX_SYS_FILE_FORMAT_TAG     (UNIV_PAGE_SIZE - 16)

/** Contents of TRX_SYS_FILE_FORMAT_TAG when valid. The file format
identifier is added to this constant. */
#define TRX_SYS_FILE_FORMAT_TAG_MAGIC_N_LOW 3645922177UL
/** Contents of TRX_SYS_FILE_FORMAT_TAG+4 when valid */
#define TRX_SYS_FILE_FORMAT_TAG_MAGIC_N_HIGH    2745987765UL
/** Contents of TRX_SYS_FILE_FORMAT_TAG when valid. The file format
identifier is added to this 64-bit constant. */
#define TRX_SYS_FILE_FORMAT_TAG_MAGIC_N                 \
    ((ib_uint64_t) TRX_SYS_FILE_FORMAT_TAG_MAGIC_N_HIGH << 32   \
     | TRX_SYS_FILE_FORMAT_TAG_MAGIC_N_LOW)
/* @} */

```