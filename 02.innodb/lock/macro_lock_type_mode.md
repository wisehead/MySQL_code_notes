#1.lock type_mode

```cpp
/** Lock modes and types */
/* @{ */
#define LOCK_MODE_MASK  0xFUL   /*!< mask used to extract mode from the
                type_mode field in a lock */
/** Lock types */
/* @{ */
#define LOCK_TABLE  16  /*!< table lock */
#define LOCK_REC    32  /*!< record lock */
#define LOCK_TYPE_MASK  0xF0UL  /*!< mask used to extract lock type from the
                type_mode field in a lock */
#if LOCK_MODE_MASK & LOCK_TYPE_MASK
# error "LOCK_MODE_MASK & LOCK_TYPE_MASK"
#endif

#define LOCK_WAIT   256 /*!< Waiting lock flag; when set, it
                means that the lock has not yet been
                granted, it is just waiting for its
                turn in the wait queue */
/* Precise modes */
#define LOCK_ORDINARY   0   /*!< this flag denotes an ordinary
                next-key lock in contrast to LOCK_GAP
                or LOCK_REC_NOT_GAP */
#define LOCK_GAP    512 /*!< when this bit is set, it means that the
                lock holds only on the gap before the record;
                for instance, an x-lock on the gap does not
                give permission to modify the record on which
                the bit is set; locks of this type are created
                when records are removed from the index chain
                of records */
#define LOCK_REC_NOT_GAP 1024   /*!< this bit means that the lock is only on
                the index record and does NOT block inserts
                to the gap before the index record; this is
                used in the case when we retrieve a record
                with a unique key, and is also used in
                locking plain SELECTs (not part of UPDATE
                or DELETE) when the user has set the READ
                COMMITTED isolation level */
#define LOCK_INSERT_INTENTION 2048 /*!< this bit is set when we place a waiting
                gap type record lock request in order to let
                an insert of an index record to wait until
                there are no conflicting locks by other
                transactions on the gap; note that this flag
                remains set when the waiting lock is granted,
                or if the lock is inherited to a neighboring
                record */
```