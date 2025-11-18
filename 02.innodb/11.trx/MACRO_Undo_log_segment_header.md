#1.Undo log segment header

```cpp
/** The offset of the undo log segment header on the first page of the undo
log segment */

#define TRX_UNDO_SEG_HDR    (TRX_UNDO_PAGE_HDR + TRX_UNDO_PAGE_HDR_SIZE)
/** Undo log segment header */
/* @{ */
/*-------------------------------------------------------------*/
#define TRX_UNDO_STATE      0   /*!< TRX_UNDO_ACTIVE, ... */
#define TRX_UNDO_LAST_LOG   2   /*!< Offset of the last undo log header
                    on the segment header page, 0 if
                    none */
#define TRX_UNDO_FSEG_HEADER    4   /*!< Header for the file segment which
                    the undo log segment occupies */
#define TRX_UNDO_PAGE_LIST  (4 + FSEG_HEADER_SIZE)
                    /*!< Base node for the list of pages in
                    the undo log segment; defined only on
                    the undo log segment's first page */
/*-------------------------------------------------------------*/
/** Size of the undo log segment header */
#define TRX_UNDO_SEG_HDR_SIZE   (4 + FSEG_HEADER_SIZE + FLST_BASE_NODE_SIZE)
/* @} */

描述这个 FSP Segment，我们曾说过，Segment 的第一个页往往由调用者存放着这一类数据页的描述信息

TRX_UNDO_STATE（18，2字节）：此 Segment 状态，TRX_UNDO_ACTIVE ...
TRX_UNDO_LAST_LOG（20，2字节）：当前页面的最后一条Undo日志记录的【Undo Log Header】
TRX_UNDO_FSEG_HEADER（24，10字节）：见下文 “事务的开始与提交”
TRX_UNDO_PAGE_LIST（34，16字节）：对于同一个Slot下的【Undo Log Header Page】和【Normal Undo Page】构成的双向链表的“首节点”

```