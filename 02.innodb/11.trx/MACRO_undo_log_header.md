#1.undo log header

```cpp
/** The undo log header. There can be several undo log headers on the first
page of an update undo log segment. */
/* @{ */
/*-------------------------------------------------------------*/
#define TRX_UNDO_TRX_ID     0   /*!< Transaction id */
#define TRX_UNDO_TRX_NO     8   /*!< Transaction number of the
                    transaction; defined only if the log
                    is in a history list */
#define TRX_UNDO_DEL_MARKS  16  /*!< Defined only in an update undo
                    log: TRUE if the transaction may have
                    done delete markings of records, and
                    thus purge is necessary */
#define TRX_UNDO_LOG_START  18  /*!< Offset of the first undo log record
                    of this log on the header page; purge
                    may remove undo log record from the
                    log start, and therefore this is not
                    necessarily the same as this log
                    header end offset */
#define TRX_UNDO_XID_EXISTS 20  /*!< TRUE if undo log header includes
                    X/Open XA transaction identification
                    XID */
#define TRX_UNDO_DICT_TRANS 21  /*!< TRUE if the transaction is a table
                    create, index create, or drop
                    transaction: in recovery
                    the transaction cannot be rolled back
                    in the usual way: a 'rollback' rather
                    means dropping the created or dropped
                    table, if it still exists */
#define TRX_UNDO_TABLE_ID   22  /*!< Id of the table if the preceding
                    field is TRUE */
#define TRX_UNDO_NEXT_LOG   30  /*!< Offset of the next undo log header
                    on this page, 0 if none */
#define TRX_UNDO_PREV_LOG   32  /*!< Offset of the previous undo log
                    header on this page, 0 if none */
#define TRX_UNDO_HISTORY_NODE   34  /*!< If the log is put to the history
                    list, the file list node is here */
/*-------------------------------------------------------------*/
每个事务都有一个 Undo Log Header，当（UPDATE/DELETE）事务结束后，Undo Log Header被加入到 History List 中。注：Undo Log Header 仅存在于 Undo Log Header Page 上

TRX_UNDO_TRX_ID（0，8字节）：事务ID（事务开始的逻辑时间）

TRX_UNDO_TRX_NO（8，8字节）：事务NO.（事务结束的逻辑时间）
TRX_UNDO_DEL_MARKS（16，2字节）：如果事务可能造成“DELETE MARK”某个索引记录
TRX_UNDO_LOG_START（18，2字节）：此事务中第一个 undo record 的偏移

TRX_UNDO_XID_EXISTS（20，1字节）：Undo Log Header 中是否 XID？

TRX_UNDO_DICT_TRANS（21，1字节）：事务是否是"create table"/"create index or drop"？ 

TRX_UNDO_TABLE_ID（22，8字节）：如果TRX_UNDO_DICT_TRANS是TRUE，保存的是table_id

TRX_UNDO_NEXT_LOG（30，2字节）：当前 Page（Undo Log Header Page）的下一个 Undo Log Header

TRX_UNDO_PREV_LOG（32，2字节）：当前 Page（Undo Log Header Page）的上一个 Undo Log Header

TRX_UNDO_HISTORY_NODE（34，6字节）：指向 History List 中下一个 Page（Undo Log Header Page）
```