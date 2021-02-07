#1.struct sel_node_t

```cpp
/** Select statement node */
struct sel_node_t{
    que_common_t    common;     /*!< node type: QUE_NODE_SELECT */
    enum sel_node_state
            state;  /*!< node state */
    que_node_t* select_list;    /*!< select list */
    sym_node_t* into_list;  /*!< variables list or NULL */
    sym_node_t* table_list; /*!< table list */
    ibool       asc;        /*!< TRUE if the rows should be fetched
                    in an ascending order */
    ibool       set_x_locks;    /*!< TRUE if the cursor is for update or
                    delete, which means that a row x-lock
                    should be placed on the cursor row */
    ulint       row_lock_mode;  /*!< LOCK_X or LOCK_S */
    ulint       n_tables;   /*!< number of tables */
    ulint       fetch_table;    /*!< number of the next table to access
                    in the join */
    plan_t*     plans;      /*!< array of n_tables many plan nodes
                    containing the search plan and the
                    search data structures */
    que_node_t* search_cond;    /*!< search condition */
    ReadView*   read_view;  /*!< if the query is a non-locking
                    consistent read, its read view is
                    placed here, otherwise NULL */
    ibool       consistent_read;/*!< TRUE if the select is a consistent,
                    non-locking read */
    order_node_t*   order_by;   /*!< order by column definition, or
                    NULL */
    ibool       is_aggregate;   /*!< TRUE if the select list consists of
                    aggregate functions */
    ibool       aggregate_already_fetched;
                    /*!< TRUE if the aggregate row has
                    already been fetched for the current
                    cursor */
    ibool       can_get_updated;/*!< this is TRUE if the select
                    is in a single-table explicit
                    cursor which can get updated
                    within the stored procedure,
                    or in a searched update or
                    delete; NOTE that to determine
                    of an explicit cursor if it
                    can get updated, the parser
                    checks from a stored procedure
                    if it contains positioned
                    update or delete statements */
    sym_node_t* explicit_cursor;/*!< not NULL if an explicit cursor */
    UT_LIST_BASE_NODE_T(sym_node_t)
            copy_variables; /*!< variables whose values we have to
                    copy when an explicit cursor is opened,
                    so that they do not change between
                    fetches */
};

```