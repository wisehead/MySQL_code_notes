#1.Macro FIL\_PAGE_HEADER

```cpp
/** The byte offsets on a file page for various variables @{ */
#define FIL_PAGE_SPACE_OR_CHKSUM 0  /*!< in < MySQL-4.0.14 space id the
                    page belongs to (== 0) but in later
                    versions the 'new' checksum of the
                    page */
#define FIL_PAGE_OFFSET     4   /*!< page offset inside space */
#define FIL_PAGE_PREV       8   /*!< if there is a 'natural'
                    predecessor of the page, its
                    offset.  Otherwise FIL_NULL.
                    This field is not set on BLOB
                    pages, which are stored as a
                    singly-linked list.  See also
                    FIL_PAGE_NEXT. */
#define FIL_PAGE_NEXT       12  /*!< if there is a 'natural' successor
                    of the page, its offset.
                    Otherwise FIL_NULL.
                    B-tree index pages
                    (FIL_PAGE_TYPE contains FIL_PAGE_INDEX)
                    on the same PAGE_LEVEL are maintained
                    as a doubly linked list via
                    FIL_PAGE_PREV and FIL_PAGE_NEXT
                    in the collation order of the
                    smallest user record on each page. */
#define FIL_PAGE_LSN        16  /*!< lsn of the end of the newest
                    modification log record to the page */
#define FIL_PAGE_TYPE       24  /*!< file page type: FIL_PAGE_INDEX,...,
                    2 bytes.

                    The contents of this field can only
                    be trusted in the following case:
                    if the page is an uncompressed
                    B-tree index page, then it is
                    guaranteed that the value is
                    FIL_PAGE_INDEX.
                    The opposite does not hold.

                    In tablespaces created by
                    MySQL/InnoDB 5.1.7 or later, the
                    contents of this field is valid
                    for all uncompressed pages. */
#define FIL_PAGE_FILE_FLUSH_LSN 26  /*!< this is only defined for the
                    first page in a system tablespace
                    data file (ibdata*, not *.ibd):
                    the file has been flushed to disk
                    at least up to this lsn */
#define FIL_PAGE_ARCH_LOG_NO_OR_SPACE_ID  34 /*!< starting from 4.1.x this
                    contains the space id of the page */
#define FIL_PAGE_SPACE_ID  FIL_PAGE_ARCH_LOG_NO_OR_SPACE_ID

#define FIL_PAGE_DATA       38  /*!< start of the data on the page */
/* @} */
/** File page trailer @{ */
#define FIL_PAGE_END_LSN_OLD_CHKSUM 8   /*!< the low 4 bytes of this are used
                    to store the page checksum, the
                    last 4 bytes should be identical
                    to the last 4 bytes of FIL_PAGE_LSN */
#define FIL_PAGE_DATA_END   8   /*!< size of the page trailer */
/* @} */

Page Header
FIL_PAGE_SPACE_OR_CHKSUM：在 MySQL 4.0.14 之后是 Checksum
FIL_PAGE_OFFSET："page no"，是 Page 在文件中的逻辑偏移量（0，1，2 ...）
FIL_PAGE_PREV / FIL_PAGE_NEXT：所有 Page 构成双向链表
FIL_PAGE_LSN：最新的修改该页的 mtr end lsn
FIL_PAGE_TYPE：页的类型；常用的包括
Index Page：FIL_PAGE_INDEX 
Log Page：FIL_PAGE_UNDO_LOG
Descripter Page：FIL_PAGE_INODE / FIL_PAGE_IBUF_BITMAP / FIL_PAGE_TYPE_SYS / FIL_PAGE_TYPE_FSP_HDR
FIL_PAGE_FILE_FLUSH_LSN：仅定义在系统表空间的第一个页，是判断 InnoDB 是否需要 Crash Recovery 的条件之一（另一个是 recv_sys->scanned_lsn > recv_sys→checkpoint）
FIL_PAGE_SPACE_ID：Page 所归属的 tablespace id
Page Trailer
FIL_PAGE_END_LSN_OLD_CHKSUM：前四个字节表示Checksum，后四个字节表示FIL_PAGE_LSN的后四个字节                    
```