#1.struct purge_node_t

```cpp

/* Purge node structure */

struct purge_node_t{
    que_common_t    common; /*!< node type: QUE_NODE_PURGE */
    /*----------------------*/
    /* Local storage for this graph node */
    roll_ptr_t  roll_ptr;/* roll pointer to undo log record */
    ib_vector_t*    undo_recs;/*!< Undo recs to purge */

    undo_no_t   undo_no;/*!< undo number of the record */

    ulint       rec_type;/*!< undo log record type: TRX_UNDO_INSERT_REC,
                ... */
    dict_table_t*   table;  /*!< table where purge is done */

    ulint       cmpl_info;/* compiler analysis info of an update */

    upd_t*      update; /*!< update vector for a clustered index
                record */
    dtuple_t*   ref;    /*!< NULL, or row reference to the next row to
                handle */
    dtuple_t*   row;    /*!< NULL, or a copy (also fields copied to
                heap) of the indexed fields of the row to
                handle */
    dict_index_t*   index;  /*!< NULL, or the next index whose record should
                be handled */
    mem_heap_t* heap;   /*!< memory heap used as auxiliary storage for
                row; this must be emptied after a successful
                purge of a row */
    ibool       found_clust;/* TRUE if the clustered index record
                determined by ref was found in the clustered
                index, and we were able to position pcur on
                it */
    btr_pcur_t  pcur;   /*!< persistent cursor used in searching the
                clustered index record */
    ibool       done;   /* Debug flag */
    trx_id_t    trx_id; /*!< trx id for this purging record */

#ifdef UNIV_DEBUG
    /***********************************************************//**
    Validate the persisent cursor. The purge node has two references
    to the clustered index record - one via the ref member, and the
    other via the persistent cursor.  These two references must match
    each other if the found_clust flag is set.
    @return true if the persistent cursor is consistent with
    the ref member.*/
    bool    validate_pcur();
#endif
};

```