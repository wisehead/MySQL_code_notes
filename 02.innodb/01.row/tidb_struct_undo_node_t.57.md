#1.struct undo_node_t

```cpp
/** Undo node structure */
struct undo_node_t{
    que_common_t    common; /*!< node type: QUE_NODE_UNDO */
    enum undo_exec  state;  /*!< node execution state */
    trx_t*      trx;    /*!< trx for which undo is done */
    roll_ptr_t  roll_ptr;/*!< roll pointer to undo log record */
    trx_undo_rec_t* undo_rec;/*!< undo log record */
    undo_no_t   undo_no;/*!< undo number of the record */
    ulint       rec_type;/*!< undo log record type: TRX_UNDO_INSERT_REC,
                ... */
    trx_id_t    new_trx_id; /*!< trx id to restore to clustered index
                record */
    btr_pcur_t  pcur;   /*!< persistent cursor used in searching the
                clustered index record */
    dict_table_t*   table;  /*!< table where undo is done */
    ulint       cmpl_info;/*!< compiler analysis of an update */
    upd_t*      update; /*!< update vector for a clustered index
                record */
    dtuple_t*   ref;    /*!< row reference to the next row to handle */
    dtuple_t*   row;    /*!< a copy (also fields copied to heap) of the
                row to handle */
    row_ext_t*  ext;    /*!< NULL, or prefixes of the externally
                stored columns of the row */
    dtuple_t*   undo_row;/*!< NULL, or the row after undo */
    row_ext_t*  undo_ext;/*!< NULL, or prefixes of the externally
                stored columns of undo_row */
    dict_index_t*   index;  /*!< the next index whose record should be
                handled */
    mem_heap_t* heap;   /*!< memory heap used as auxiliary storage for
                row; this must be emptied after undo is tried
                on a row */
};


```