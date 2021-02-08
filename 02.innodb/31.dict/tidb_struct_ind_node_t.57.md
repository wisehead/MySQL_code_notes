#1.struct ind_node_t

```cpp
/* Index create node struct */

struct ind_node_t{
    que_common_t    common;     /*!< node type: QUE_NODE_INDEX_CREATE */
    dict_index_t*   index;      /*!< index to create, built as a
                    memory data structure with
                    dict_mem_... functions */
    ins_node_t* ind_def;    /*!< child node which does the insert of
                    the index definition; the row to be
                    inserted is built by the parent node  */
    ins_node_t* field_def;  /*!< child node which does the inserts
                    of the field definitions; the row to
                    be inserted is built by the parent
                    node  */
    /*----------------------*/
    /* Local storage for this graph node */
    ulint       state;      /*!< node execution state */
    ulint       page_no;    /* root page number of the index */
    dict_table_t*   table;      /*!< table which owns the index */
    dtuple_t*   ind_row;    /* index definition row built */
    ulint       field_no;   /* next field definition to insert */
    mem_heap_t* heap;       /*!< memory heap used as auxiliary
                    storage */
    const dict_add_v_col_t*
            add_v;      /*!< new virtual columns that being
                    added along with an add index call */
};

```