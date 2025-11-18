#1.Transaction undo log page header

```cpp
/** The offset of the undo log page header on pages of the undo log */
#define TRX_UNDO_PAGE_HDR   FSEG_PAGE_DATA
/*-------------------------------------------------------------*/
/** Transaction undo log page header offsets */
/* @{ */
#define TRX_UNDO_PAGE_TYPE  0   /*!< TRX_UNDO_INSERT or
                    TRX_UNDO_UPDATE */
#define TRX_UNDO_PAGE_START 2   /*!< Byte offset where the undo log
                    records for the LATEST transaction
                    start on this page (remember that
                    in an update undo log, the first page
                    can contain several undo logs) */
#define TRX_UNDO_PAGE_FREE  4   /*!< On each page of the undo log this
                    field contains the byte offset of the
                    first free byte on the page */
#define TRX_UNDO_PAGE_NODE  6   /*!< The file list node in the chain
                    of undo log pages */
/*-------------------------------------------------------------*/
#define TRX_UNDO_PAGE_HDR_SIZE  (6 + FLST_NODE_SIZE)
                    /*!< Size of the transaction undo
                    log page header, in bytes */
/* @} */

Undo Page Header（TRX_UNDO_PAGE_HDR）
TRX_UNDO_PAGE_TYPE（0，2字节）：类型；使用该页的事务的类型。TRX_UNDO_INSERT / TRX_UNDO_UPDATE
TRX_UNDO_PAGE_START（2，2字节）：（时间上）最近一个事务的 undo 日志记录起始地址
TRX_UNDO_PAGE_FREE（4，2字节）：当前页面空闲的起始地址，使用该页的事务从这个位置开始写 undo log record
TRX_UNDO_PAGE_NODE（6，12字节）：对于同一个 Slot 下的【Undo Log Header Page】和【Normal Undo Page】构成的双向链表，双向链表的“中间节点”
```