#1.struct fil_node_t

```cpp
/** File node of a tablespace or the log data space */
struct fil_node_t {
    fil_space_t*    space;  /*!< backpointer to the space where this node
                belongs */
    char*       name;   /*!< path to the file */
    ibool       open;   /*!< TRUE if file open */
    os_file_t   handle; /*!< OS handle to the file, if file open */
    os_event_t  sync_event;/*!< Condition event to group and
                serialize calls to fsync */
    ibool       is_raw_disk;/*!< TRUE if the 'file' is actually a raw
                device or a raw disk partition */
    ulint       size;   /*!< size of the file in database pages, 0 if
                not known yet; the possible last incomplete
                megabyte may be ignored if space == 0 */
    ulint       n_pending;
                /*!< count of pending i/o's on this file;
                closing of the file is not allowed if
                this is > 0 */
    ulint       n_pending_flushes;
                /*!< count of pending flushes on this file;
                closing of the file is not allowed if
                this is > 0 */
    ibool       being_extended;
                /*!< TRUE if the node is currently
                being extended. */
    ib_int64_t  modification_counter;/*!< when we write to the file we
                increment this by one */
    ib_int64_t  flush_counter;/*!< up to what
                modification_counter value we have
                flushed the modifications to disk */
    UT_LIST_NODE_T(fil_node_t) chain;
                /*!< link field for the file chain */
    UT_LIST_NODE_T(fil_node_t) LRU;
                /*!< link field for the LRU list */
    ulint       magic_n;/*!< FIL_NODE_MAGIC_N */
};
```