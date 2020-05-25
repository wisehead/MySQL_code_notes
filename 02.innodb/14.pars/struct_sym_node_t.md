#1.sym_node_t

```cpp
/** Symbol table node */
struct sym_node_t{
    que_common_t            common;     /*!< node type:
                            QUE_NODE_SYMBOL */
    /* NOTE: if the data field in 'common.val' is not NULL and the symbol
    table node is not for a temporary column, the memory for the value has
    been allocated from dynamic memory and it should be freed when the
    symbol table is discarded */

    /* 'alias' and 'indirection' are almost the same, but not quite.
    'alias' always points to the primary instance of the variable, while
    'indirection' does the same only if we should use the primary
    instance's values for the node's data. This is usually the case, but
    when initializing a cursor (e.g., "DECLARE CURSOR c IS SELECT * FROM
    t WHERE id = x;"), we copy the values from the primary instance to
    the cursor's instance so that they are fixed for the duration of the
    cursor, and set 'indirection' to NULL. If we did not, the value of
    'x' could change between fetches and things would break horribly.

    TODO: It would be cleaner to make 'indirection' a boolean field and
    always use 'alias' to refer to the primary node. */

    sym_node_t*         indirection;    /*!< pointer to
                            another symbol table
                            node which contains
                            the value for this
                            node, NULL otherwise */
    sym_node_t*         alias;      /*!< pointer to
                            another symbol table
                            node for which this
                            node is an alias,
                            NULL otherwise */
    UT_LIST_NODE_T(sym_node_t)  col_var_list;   /*!< list of table
                            columns or a list of
                            input variables for an
                            explicit cursor */
    ibool               copy_val;   /*!< TRUE if a column
                            and its value should
                            be copied to dynamic
                            memory when fetched */
    ulint               field_nos[2];   /*!< if a column, in
                            the position
                            SYM_CLUST_FIELD_NO is
                            the field number in the
                            clustered index; in
                            the position
                            SYM_SEC_FIELD_NO
                            the field number in the
                            non-clustered index to
                            use first; if not found
                            from the index, then
                            ULINT_UNDEFINED */
    ibool               resolved;   /*!< TRUE if the
                            meaning of a variable
                            or a column has been
                            resolved; for literals
                            this is always TRUE */
    enum sym_tab_entry      token_type; /*!< type of the
                            parsed token */
    const char*         name;       /*!< name of an id */
    ulint               name_len;   /*!< id name length */
    dict_table_t*           table;      /*!< table definition
                            if a table id or a
                            column id */
    ulint               col_no;     /*!< column number if a
                            column */
    sel_buf_t*          prefetch_buf;   /*!< NULL, or a buffer
                            for cached column
                            values for prefetched
                            rows */
    sel_node_t*         cursor_def; /*!< cursor definition
                            select node if a
                            named cursor */
    ulint               param_type; /*!< PARS_INPUT,
                            PARS_OUTPUT, or
                            PARS_NOT_PARAM if not a
                            procedure parameter */
    sym_tab_t*          sym_table;  /*!< back pointer to
                            the symbol table */
    UT_LIST_NODE_T(sym_node_t)  sym_list;   /*!< list of symbol
                            nodes */
    sym_node_t*         like_node;  /* LIKE operator node*/
};                            
```