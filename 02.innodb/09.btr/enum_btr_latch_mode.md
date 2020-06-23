#1.enum btr_latch_mode

```cpp
/** Latching modes for btr_cur_search_to_nth_level(). */
enum btr_latch_mode {
    /** Search a record on a leaf page and S-latch it. */
    BTR_SEARCH_LEAF = RW_S_LATCH,
    /** (Prepare to) modify a record on a leaf page and X-latch it. */
    BTR_MODIFY_LEAF = RW_X_LATCH,
    /** Obtain no latches. */
    BTR_NO_LATCHES = RW_NO_LATCH,
    /** Start modifying the entire B-tree. */
    BTR_MODIFY_TREE = 33,
    /** Continue modifying the entire B-tree. */
    BTR_CONT_MODIFY_TREE = 34,
    /** Search the previous record. */
    BTR_SEARCH_PREV = 35,
    /** Modify the previous record. */
    BTR_MODIFY_PREV = 36,
    /** Start searching the entire B-tree. */
    BTR_SEARCH_TREE = 37,
    /** Continue searching the entire B-tree. */
    BTR_CONT_SEARCH_TREE = 38
};
```

#2.other flags for latch_mode

```cpp
/* BTR_INSERT, BTR_DELETE and BTR_DELETE_MARK are mutually exclusive. */

/** If this is ORed to btr_latch_mode, it means that the search tuple
will be inserted to the index, at the searched position.
When the record is not in the buffer pool, try to use the insert buffer. */
#define BTR_INSERT      512

/** This flag ORed to btr_latch_mode says that we do the search in query
optimization */
#define BTR_ESTIMATE        1024

/** This flag ORed to BTR_INSERT says that we can ignore possible
UNIQUE definition on secondary indexes when we decide if we can use
the insert buffer to speed up inserts */
#define BTR_IGNORE_SEC_UNIQUE   2048

/** Try to delete mark the record at the searched position using the
insert/delete buffer when the record is not in the buffer pool. */
#define BTR_DELETE_MARK     4096

/** Try to purge the record at the searched position using the insert/delete
buffer when the record is not in the buffer pool. */
#define BTR_DELETE      8192

/** In the case of BTR_SEARCH_LEAF or BTR_MODIFY_LEAF, the caller is
already holding an S latch on the index tree */
#define BTR_ALREADY_S_LATCHED   16384

/** In the case of BTR_MODIFY_TREE, the caller specifies the intention
to insert record only. It is used to optimize block->lock range.*/
#define BTR_LATCH_FOR_INSERT    32768

/** In the case of BTR_MODIFY_TREE, the caller specifies the intention
to delete record only. It is used to optimize block->lock range.*/
#define BTR_LATCH_FOR_DELETE    65536

#define BTR_LATCH_MODE_WITHOUT_FLAGS(latch_mode)    \
    ((latch_mode) & ~(BTR_INSERT            \
              | BTR_DELETE_MARK     \
              | BTR_DELETE          \
              | BTR_ESTIMATE        \
              | BTR_IGNORE_SEC_UNIQUE   \
              | BTR_ALREADY_S_LATCHED       \
              | BTR_LATCH_FOR_INSERT        \
              | BTR_LATCH_FOR_DELETE))
#define BTR_LATCH_MODE_WITHOUT_INTENTION(latch_mode)    \
        ((latch_mode) & ~(BTR_LATCH_FOR_INSERT      \
              | BTR_LATCH_FOR_DELETE))
              
```