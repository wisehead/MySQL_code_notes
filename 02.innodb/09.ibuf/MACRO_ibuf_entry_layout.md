#1.ibuf entry layout

```cpp
#define IBUF_REC_FIELD_SPACE    0   /*!< in the pre-4.1 format,
                    the page number. later, the space_id */
#define IBUF_REC_FIELD_MARKER   1   /*!< starting with 4.1, a marker
                    consisting of 1 byte that is 0 */
#define IBUF_REC_FIELD_PAGE 2   /*!< starting with 4.1, the
                    page number */
#define IBUF_REC_FIELD_METADATA 3   /* the metadata field */
#define IBUF_REC_FIELD_USER 4   /* first user field */

/* Various constants for checking the type of an ibuf record and extracting
data from it. For details, see the description of the record format at the
top of this file. */

/** @name Format of the IBUF_REC_FIELD_METADATA of an insert buffer record
The fourth column in the MySQL 5.5 format contains an operation
type, counter, and some flags. */
/* @{ */
#define IBUF_REC_INFO_SIZE  4   /*!< Combined size of info fields at
                    the beginning of the fourth field */
#if IBUF_REC_INFO_SIZE >= DATA_NEW_ORDER_NULL_TYPE_BUF_SIZE
# error "IBUF_REC_INFO_SIZE >= DATA_NEW_ORDER_NULL_TYPE_BUF_SIZE"
#endif

/* Offsets for the fields at the beginning of the fourth field */
#define IBUF_REC_OFFSET_COUNTER 0   /*!< Operation counter */
#define IBUF_REC_OFFSET_TYPE    2   /*!< Type of operation */
#define IBUF_REC_OFFSET_FLAGS   3   /*!< Additional flags */

其缓存的每一个操作叫做一个 entry，物理结构是（详见 ibuf_entry_build）：

IBUF_REC_FIELD_SPACE：对应二级索引页的 space id

IBUF_REC_FIELD_MARKER：用于区分新旧版本的 entry 格式，目前默认值为0

IBUF_REC_FIELD_PAGE_NO：对应二级索引页的 page no

IBUF_REC_OFFSET_COUNTER：对于同一个二级索引页，其 entry 的递增序号（非单调递增，详见下文）

IBUF_REC_OFFSET_TYPE：缓存的操作的类型，IBUF_OP_INSERT / IBUF_OP_DELETE_MARK / IBUF_OP_DELETE

IBUF_REC_OFFSET_FLAGS：待操作的用户记录格式，REDUNDANT / COMPACT

IBUF_REC_FIELD_USER：用户记录


```