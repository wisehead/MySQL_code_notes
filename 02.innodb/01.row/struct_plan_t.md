#1.struct plan_t

```cpp
/** Query plan */
struct plan_t {
  dict_table_t *table; /*!< table struct in the dictionary
                       cache */
  dict_index_t *index; /*!< table index used in the search */
  btr_pcur_t pcur;     /*!< persistent cursor used to search
                       the index */
  ibool asc;           /*!< TRUE if cursor traveling upwards */
  ibool pcur_is_open;  /*!< TRUE if pcur has been positioned
                       and we can try to fetch new rows */
  ibool cursor_at_end; /*!< TRUE if the cursor is open but
                       we know that there are no more
                       qualifying rows left to retrieve from
                       the index tree; NOTE though, that
                       there may still be unprocessed rows in
                       the prefetch stack; always FALSE when
                       pcur_is_open is FALSE */
  ibool stored_cursor_rec_processed;
  /*!< TRUE if the pcur position has been
  stored and the record it is positioned
  on has already been processed */
  que_node_t **tuple_exps; /*!< array of expressions
                           which are used to calculate
                           the field values in the search
                           tuple: there is one expression
                           for each field in the search
                           tuple */
  dtuple_t *tuple;         /*!< search tuple */
  page_cur_mode_t mode;    /*!< search mode: PAGE_CUR_G, ... */
  ulint n_exact_match;     /*!< number of first fields in
                           the search tuple which must be
                           exactly matched */
  ibool unique_search;     /*!< TRUE if we are searching an
                           index record with a unique key */
  ulint n_rows_fetched;    /*!< number of rows fetched using pcur
                           after it was opened */
  ulint n_rows_prefetched; /*!< number of prefetched rows cached
                         for fetch: fetching several rows in
                         the same mtr saves CPU time */
  ulint first_prefetched;  /*!< index of the first cached row in
                          select buffer arrays for each column */
  ibool no_prefetch;       /*!< no prefetch for this table */
  sym_node_list_t columns; /*!< symbol table nodes for the columns
                           to retrieve from the table */
  UT_LIST_BASE_NODE_T(func_node_t)
  end_conds; /*!< conditions which determine the
             fetch limit of the index segment we
             have to look at: when one of these
             fails, the result set has been
             exhausted for the cursor in this
             index; these conditions are normalized
             so that in a comparison the column
             for this table is the first argument */
  UT_LIST_BASE_NODE_T(func_node_t)
  other_conds;               /*!< the rest of search conditions we can
                             test at this table in a join */
  ibool must_get_clust;      /*!< TRUE if index is a non-clustered
                             index and we must also fetch the
                             clustered index record; this is the
                             case if the non-clustered record does
                             not contain all the needed columns, or
                             if this is a single-table explicit
                             cursor, or a searched update or
                             delete */
  ulint *clust_map;          /*!< map telling how clust_ref is built
                             from the fields of a non-clustered
                             record */
  dtuple_t *clust_ref;       /*!< the reference to the clustered
                             index entry is built here if index is
                             a non-clustered index */
  btr_pcur_t clust_pcur;     /*!< if index is non-clustered, we use
                             this pcur to search the clustered
                             index */
  mem_heap_t *old_vers_heap; /*!< memory heap used in building an old
                             version of a row, or NULL */
};
                         
```