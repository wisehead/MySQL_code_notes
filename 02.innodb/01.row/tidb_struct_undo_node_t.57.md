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

#2.enum undo_exec

```cpp
/* A single query thread will try to perform the undo for all successive
versions of a clustered index record, if the transaction has modified it
several times during the execution which is rolled back. It may happen
that the task is transferred to another query thread, if the other thread
is assigned to handle an undo log record in the chain of different versions
of the record, and the other thread happens to get the x-latch to the
clustered index record at the right time.
    If a query thread notices that the clustered index record it is looking
for is missing, or the roll ptr field in the record doed not point to the
undo log record the thread was assigned to handle, then it gives up the undo
task for that undo log record, and fetches the next. This situation can occur
just in the case where the transaction modified the same record several times
and another thread is currently doing the undo for successive versions of
that index record. */

/** Execution state of an undo node */
enum undo_exec {
    UNDO_NODE_FETCH_NEXT = 1,   /*!< we should fetch the next
                    undo log record */
    UNDO_NODE_INSERT,       /*!< undo a fresh insert of a
                    row to a table */
    UNDO_NODE_MODIFY        /*!< undo a modify operation
                    (DELETE or UPDATE) on a row
                    of a table */
};
```