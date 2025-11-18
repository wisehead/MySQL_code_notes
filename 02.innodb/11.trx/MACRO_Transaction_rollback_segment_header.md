#1.Transaction_rollback_segment_header

```cpp
/* Transaction rollback segment header */
/*-------------------------------------------------------------*/
#define TRX_RSEG_MAX_SIZE   0   /* Maximum allowed size for rollback
                    segment in pages */
#define TRX_RSEG_HISTORY_SIZE   4   /* Number of file pages occupied
                    by the logs in the history list */
#define TRX_RSEG_HISTORY    8   /* The update undo logs for committed
                    transactions */
#define TRX_RSEG_FSEG_HEADER    (8 + FLST_BASE_NODE_SIZE)
                    /* Header for the file segment where
                    this page is placed */
#define TRX_RSEG_UNDO_SLOTS (8 + FLST_BASE_NODE_SIZE + FSEG_HEADER_SIZE)
                    /* Undo log segment slots */
                    
TRX_RSEG_MAX_SIZE（0，4字节）：该回滚段允许的最大容量（number in page）
TRX_RSEG_HISTORY_SIZE（4，4字节）：在 History List 中，事务所占用的容量（number in page）
TRX_RSEG_HISTORY（8，16字节）：History List 链表首地址
TRX_RSEG_FSEG_HEADER（24，10字节）：参考 InnoDB（十三）：Tablespace Managment，用于记录 Segment 申请的 INODE Entry
TRX_RSEG_UNDO_SLOTS（34，1024*4字节）：该回滚段的1024个 Slot 数组首地址，每个 Slot 占用4字节
/*-------------------------------------------------------------*/

```