#1. TRX_UNDO_ACTIVE

```cpp
/* States of an undo log segment */
#define TRX_UNDO_ACTIVE     1   /* contains an undo log of an active
                    transaction */
#define TRX_UNDO_CACHED     2   /* cached for quick reuse */
#define TRX_UNDO_TO_FREE    3   /* insert undo segment can be freed */
#define TRX_UNDO_TO_PURGE   4   /* update undo segment will not be
                    reused: it can be freed in purge when
                    all undo data in it is removed */
#define TRX_UNDO_PREPARED   5   /* contains an undo log of an
                    prepared transaction */
```