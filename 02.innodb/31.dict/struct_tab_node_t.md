#1.struct tab_node_t

```cpp
/* Table create node structure */
struct tab_node_t{
    que_common_t    common; /*!< node type: QUE_NODE_TABLE_CREATE */
    dict_table_t*   table;  /*!< table to create, built as a memory data
                structure with dict_mem_... functions */
    ins_node_t* tab_def; /* child node which does the insert of
                the table definition; the row to be inserted
                is built by the parent node  */
    ins_node_t* col_def; /* child node which does the inserts of
                the column definitions; the row to be inserted
                is built by the parent node  */
    commit_node_t*  commit_node;
                /* child node which performs a commit after
                a successful table creation */
    /*----------------------*/
    /* Local storage for this graph node */
    ulint       state;  /*!< node execution state */
    ulint       col_no; /*!< next column definition to insert */
    mem_heap_t* heap;   /*!< memory heap used as auxiliary storage */
};
```