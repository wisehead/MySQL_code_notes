#1.Logging modes for a mini-transaction

```cpp
/* Logging modes for a mini-transaction */
#define MTR_LOG_ALL     21  /* default mode: log all operations
                    modifying disk-based data */
#define MTR_LOG_NONE        22  /* log no operations */
#define MTR_LOG_NO_REDO     23  /* Don't generate REDO */
/*#define   MTR_LOG_SPACE   23 */   /* log only operations modifying
                    file space page allocation data
                    (operations in fsp0fsp.* ) */
#define MTR_LOG_SHORT_INSERTS   24  /* inserts are logged in a shorter
                    form */

```