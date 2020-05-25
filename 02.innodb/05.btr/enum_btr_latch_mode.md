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