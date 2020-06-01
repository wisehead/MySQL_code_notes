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
/*-------------------------------------------------------------*/

```