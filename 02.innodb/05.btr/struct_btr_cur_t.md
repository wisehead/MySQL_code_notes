#1.struct btr_cur_t

```cpp
/** The tree cursor: the definition appears here only for the compiler
to know struct size! */
struct btr_cur_t {
    dict_index_t*   index;      /*!< index where positioned */
    page_cur_t  page_cur;   /*!< page cursor */
    purge_node_t*   purge_node; /*!< purge node, for BTR_DELETE */
    buf_block_t*    left_block; /*!< this field is used to store
                    a pointer to the left neighbor
                    page, in the cases
                    BTR_SEARCH_PREV and
                    BTR_MODIFY_PREV */
    /*------------------------------*/
    que_thr_t*  thr;        /*!< this field is only used
                    when btr_cur_search_to_nth_level
                    is called for an index entry
                    insertion: the calling query
                    thread is passed here to be
                    used in the insert buffer */
    /*------------------------------*/
    /** The following fields are used in
    btr_cur_search_to_nth_level to pass information: */
    /* @{ */
    enum btr_cur_method flag;   /*!< Search method used */
    ulint       tree_height;    /*!< Tree height if the search is done
                    for a pessimistic insert or update
                    operation */
    ulint       up_match;   /*!< If the search mode was PAGE_CUR_LE,
                    the number of matched fields to the
                    the first user record to the right of
                    the cursor record after
                    btr_cur_search_to_nth_level;
                    for the mode PAGE_CUR_GE, the matched
                    fields to the first user record AT THE
                    CURSOR or to the right of it;
                    NOTE that the up_match and low_match
                    values may exceed the correct values
                    for comparison to the adjacent user
                    record if that record is on a
                    different leaf page! (See the note in
                    row_ins_duplicate_error_in_clust.) */
    ulint       up_bytes;   /*!< number of matched bytes to the
                    right at the time cursor positioned;
                    only used internally in searches: not
                    defined after the search */
    ulint       low_match;  /*!< if search mode was PAGE_CUR_LE,
                    the number of matched fields to the
                    first user record AT THE CURSOR or
                    to the left of it after
                    btr_cur_search_to_nth_level;
                    NOT defined for PAGE_CUR_GE or any
                    other search modes; see also the NOTE
                    in up_match! */
    ulint       low_bytes;  /*!< number of matched bytes to the
                    right at the time cursor positioned;
                    only used internally in searches: not
                    defined after the search */
    ulint       n_fields;   /*!< prefix length used in a hash
                    search if hash_node != NULL */
    ulint       n_bytes;    /*!< hash prefix bytes if hash_node !=
                    NULL */
    ulint       fold;       /*!< fold value used in the search if
                    flag is BTR_CUR_HASH */
    /* @} */
    btr_path_t* path_arr;   /*!< in estimating the number of
                    rows in range, we store in this array
                    information of the path through
                    the tree */
};                    
```