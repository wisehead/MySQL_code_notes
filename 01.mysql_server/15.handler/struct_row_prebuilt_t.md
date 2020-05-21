#1.struct row_prebuilt_t

```cpp
/** A struct for (sometimes lazily) prebuilt structures in an Innobase table
handle used within MySQL; these are used to save CPU time. */

struct row_prebuilt_t {
    ulint       magic_n;    /*!< this magic number is set to
                    ROW_PREBUILT_ALLOCATED when created,
                    or ROW_PREBUILT_FREED when the
                    struct has been freed */
    dict_table_t*   table;      /*!< Innobase table handle */
    dict_index_t*   index;      /*!< current index for a search, if
                    any */
    trx_t*      trx;        /*!< current transaction handle */
    unsigned    sql_stat_start:1;/*!< TRUE when we start processing of
                    an SQL statement: we may have to set
                    an intention lock on the table,
                    create a consistent read view etc. */
    unsigned    mysql_has_locked:1;/*!< this is set TRUE when MySQL
                    calls external_lock on this handle
                    with a lock flag, and set FALSE when
                    with the F_UNLOCK flag */
    unsigned    clust_index_was_generated:1;
                    /*!< if the user did not define a
                    primary key in MySQL, then Innobase
                    automatically generated a clustered
                    index where the ordering column is
                    the row id: in this case this flag
                    is set to TRUE */
    unsigned    index_usable:1; /*!< caches the value of
                    row_merge_is_index_usable(trx,index) */
    unsigned    read_just_key:1;/*!< set to 1 when MySQL calls
                    ha_innobase::extra with the
                    argument HA_EXTRA_KEYREAD; it is enough
                    to read just columns defined in
                    the index (i.e., no read of the
                    clustered index record necessary) */
    unsigned    used_in_HANDLER:1;/*!< TRUE if we have been using this
                    handle in a MySQL HANDLER low level
                    index cursor command: then we must
                    store the pcur position even in a
                    unique search from a clustered index,
                    because HANDLER allows NEXT and PREV
                    in such a situation */
    unsigned    template_type:2;/*!< ROW_MYSQL_WHOLE_ROW,
                    ROW_MYSQL_REC_FIELDS,
                    ROW_MYSQL_DUMMY_TEMPLATE, or
                    ROW_MYSQL_NO_TEMPLATE */
    unsigned    n_template:10;  /*!< number of elements in the
                    template */
    unsigned    null_bitmap_len:10;/*!< number of bytes in the SQL NULL
                    bitmap at the start of a row in the
                    MySQL format */
    unsigned    need_to_access_clustered:1; /*!< if we are fetching
                    columns through a secondary index
                    and at least one column is not in
                    the secondary index, then this is
                    set to TRUE */
    unsigned    templ_contains_blob:1;/*!< TRUE if the template contains
                    a column with DATA_BLOB ==
                    get_innobase_type_from_mysql_type();
                    not to be confused with InnoDB
                    externally stored columns
                    (VARCHAR can be off-page too) */
    mysql_row_templ_t* mysql_template;/*!< template used to transform
                    rows fast between MySQL and Innobase
                    formats; memory for this template
                    is not allocated from 'heap' */
    mem_heap_t* heap;       /*!< memory heap from which
                    these auxiliary structures are
                    allocated when needed */
    ins_node_t* ins_node;   /*!< Innobase SQL insert node
                    used to perform inserts
                    to the table */
    byte*       ins_upd_rec_buff;/*!< buffer for storing data converted
                    to the Innobase format from the MySQL
                    format */
    const byte* default_rec;    /*!< the default values of all columns
                    (a "default row") in MySQL format */
    ulint       hint_need_to_fetch_extra_cols;
                    /*!< normally this is set to 0; if this
                    is set to ROW_RETRIEVE_PRIMARY_KEY,
                    then we should at least retrieve all
                    columns in the primary key; if this
                    is set to ROW_RETRIEVE_ALL_COLS, then
                    we must retrieve all columns in the
                    key (if read_just_key == 1), or all
                    columns in the table */
    upd_node_t* upd_node;   /*!< Innobase SQL update node used
                    to perform updates and deletes */
    trx_id_t    trx_id;     /*!< The table->def_trx_id when
                    ins_graph was built */
    que_fork_t* ins_graph;  /*!< Innobase SQL query graph used
                    in inserts. Will be rebuilt on
                    trx_id or n_indexes mismatch. */
    que_fork_t* upd_graph;  /*!< Innobase SQL query graph used
                    in updates or deletes */
    btr_pcur_t  pcur;       /*!< persistent cursor used in selects
                    and updates */
    btr_pcur_t  clust_pcur; /*!< persistent cursor used in
                    some selects and updates */
    que_fork_t* sel_graph;  /*!< dummy query graph used in
                    selects */
    dtuple_t*   search_tuple;   /*!< prebuilt dtuple used in selects */
    byte        row_id[DATA_ROW_ID_LEN];
                    /*!< if the clustered index was
                    generated, the row id of the
                    last row fetched is stored
                    here */
    doc_id_t    fts_doc_id; /* if the table has an FTS index on
                    it then we fetch the doc_id.
                    FTS-FIXME: Currently we fetch it always
                    but in the future we must only fetch
                    it when FTS columns are being
                    updated */
    dtuple_t*   clust_ref;  /*!< prebuilt dtuple used in
                    sel/upd/del */
    ulint       select_lock_type;/*!< LOCK_NONE, LOCK_S, or LOCK_X */
    ulint       stored_select_lock_type;/*!< this field is used to
                    remember the original select_lock_type
                    that was decided in ha_innodb.cc,
                    ::store_lock(), ::external_lock(),
                    etc. */
    ulint       row_read_type;  /*!< ROW_READ_WITH_LOCKS if row locks
                    should be the obtained for records
                    under an UPDATE or DELETE cursor.
                    If innodb_locks_unsafe_for_binlog
                    is TRUE, this can be set to
                    ROW_READ_TRY_SEMI_CONSISTENT, so that
                    if the row under an UPDATE or DELETE
                    cursor was locked by another
                    transaction, InnoDB will resort
                    to reading the last committed value
                    ('semi-consistent read').  Then,
                    this field will be set to
                    ROW_READ_DID_SEMI_CONSISTENT to
                    indicate that.  If the row does not
                    match the WHERE condition, MySQL will
                    invoke handler::unlock_row() to
                    clear the flag back to
                    ROW_READ_TRY_SEMI_CONSISTENT and
                    to simply skip the row.  If
                    the row matches, the next call to
                    row_search_for_mysql() will lock
                    the row.
                    This eliminates lock waits in some
                    cases; note that this breaks
                    serializability. */     
    ulint       new_rec_locks;  /*!< normally 0; if
                    srv_locks_unsafe_for_binlog is
                    TRUE or session is using READ
                    COMMITTED or READ UNCOMMITTED
                    isolation level, set in
                    row_search_for_mysql() if we set a new
                    record lock on the secondary
                    or clustered index; this is
                    used in row_unlock_for_mysql()
                    when releasing the lock under
                    the cursor if we determine
                    after retrieving the row that
                    it does not need to be locked
                    ('mini-rollback') */
    ulint       mysql_prefix_len;/*!< byte offset of the end of
                    the last requested column */
    ulint       mysql_row_len;  /*!< length in bytes of a row in the
                    MySQL format */
    ulint       n_rows_fetched; /*!< number of rows fetched after
                    positioning the current cursor */
    ulint       fetch_direction;/*!< ROW_SEL_NEXT or ROW_SEL_PREV */
    byte*       fetch_cache[MYSQL_FETCH_CACHE_SIZE];
                    /*!< a cache for fetched rows if we
                    fetch many rows from the same cursor:
                    it saves CPU time to fetch them in a
                    batch; we reserve mysql_row_len
                    bytes for each such row; these
                    pointers point 4 bytes past the
                    allocated mem buf start, because
                    there is a 4 byte magic number at the
                    start and at the end */
    ibool       keep_other_fields_on_keyread; /*!< when using fetch
                    cache with HA_EXTRA_KEYREAD, don't
                    overwrite other fields in mysql row
                    row buffer.*/
    ulint       fetch_cache_first;/*!< position of the first not yet
                    fetched row in fetch_cache */
    ulint       n_fetch_cached; /*!< number of not yet fetched rows
                    in fetch_cache */
    mem_heap_t* blob_heap;  /*!< in SELECTS BLOB fields are copied
                    to this heap */
    mem_heap_t* old_vers_heap;  /*!< memory heap where a previous
                    version is built in consistent read */
    bool        in_fts_query;   /*!< Whether we are in a FTS query */
    /*----------------------*/
    ulonglong   autoinc_last_value;
                    /*!< last value of AUTO-INC interval */
    ulonglong   autoinc_increment;/*!< The increment step of the auto
                    increment column. Value must be
                    greater than or equal to 1. Required to
                    calculate the next value */
    ulonglong   autoinc_offset; /*!< The offset passed to
                    get_auto_increment() by MySQL. Required
                    to calculate the next value */
    dberr_t     autoinc_error;  /*!< The actual error code encountered
                    while trying to init or read the
                    autoinc value from the table. We
                    store it here so that we can return
                    it to MySQL */
    /*----------------------*/
    void*       idx_cond;   /*!< In ICP, pointer to a ha_innobase,
                    passed to innobase_index_cond().
                    NULL if index condition pushdown is
                    not used. */
    ulint       idx_cond_n_cols;/*!< Number of fields in idx_cond_cols.
                    0 if and only if idx_cond == NULL. */
    /*----------------------*/
    ulint       magic_n2;   /*!< this should be the same as
                    magic_n */
    /*----------------------*/
    unsigned    innodb_api:1;   /*!< whether this is a InnoDB API
                    query */
    const rec_t*    innodb_api_rec; /*!< InnoDB API search result */
    byte*       srch_key_val1;  /*!< buffer used in converting
                    search key values from MySQL format
                    to InnoDB format.*/
    byte*       srch_key_val2;  /*!< buffer used in converting
                    search key values from MySQL format
                    to InnoDB format.*/
    uint        srch_key_val_len; /*!< Size of search key */

};                                                           
```