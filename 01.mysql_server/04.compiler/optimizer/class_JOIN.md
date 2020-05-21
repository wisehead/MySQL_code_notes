#1.class JOIN

```cpp
class JOIN :public Sql_alloc
{
  JOIN(const JOIN &rhs);                        /**< not implemented */
  JOIN& operator=(const JOIN &rhs);             /**< not implemented */
public:
  JOIN_TAB *join_tab,**best_ref;
  JOIN_TAB **map2table;    ///< mapping between table indexes and JOIN_TABs
  TABLE    **table;
  /*
    The table which has an index that allows to produce the requried ordering.
    A special value of 0x1 means that the ordering will be produced by
    passing 1st non-const table to filesort(). NULL means no such table exists.
  */
  TABLE    *sort_by_table;
  /**
    Before plan has been created, "tables" denote number of input tables in the
    query block and "primary_tables" is equal to "tables".
    After plan has been created (after JOIN::get_best_combination()),
    the JOIN_TAB objects are enumerated as follows:
    - "tables" gives the total number of allocated JOIN_TAB objects
    - "primary_tables" gives the number of input tables, including
      materialized temporary tables from semi-join operation.
    - "const_tables" are those tables among primary_tables that are detected
      to be constant.
    - "tmp_tables" is 0, 1 or 2 and counts the maximum possible number of
      intermediate tables in post-processing (ie sorting and duplicate removal).
      Later, tmp_tables will be adjusted to the correct number of
      intermediate tables, @see JOIN::make_tmp_tables_info.
    - The remaining tables (ie. tables - primary_tables - tmp_tables) are
      input tables to materialized semi-join operations.
    The tables are ordered as follows in the join_tab array:
     1. const primary table
     2. non-const primary tables
     3. intermediate sort/group tables
     4. possible holes in array
     5. semi-joined tables used with materialization strategy
  */
  uint     tables;         ///< Total number of tables in query block
  uint     primary_tables; ///< Number of primary input tables in query block
  uint     const_tables;   ///< Number of primary tables deemed constant
  uint     tmp_tables;     ///< Number of temporary tables used by query
  uint     send_group_parts;
  /**
    Indicates that grouping will be performed on the result set during
    query execution. This field belongs to query execution.

    @see make_group_fields, alloc_group_fields, JOIN::exec
  */
  bool     sort_and_group;
  bool     first_record,full_join, no_field_update;
  bool     group;            ///< If query contains GROUP BY clause
  bool     do_send_rows;
  table_map all_table_map;   ///< Set of tables contained in query
  table_map const_table_map; ///< Set of tables found to be const
  /**
     Const tables which are either:
     - not empty
     - empty but inner to a LEFT JOIN, thus "considered" not empty for the
     rest of execution (a NULL-complemented row will be used).
  */
  table_map found_const_table_map;
  table_map outer_join;      ///< Bitmap of all inner tables from outer joins
  /* Number of records produced after join + group operation */
  ha_rows  send_records;
  ha_rows found_records,examined_rows,row_limit;
  // m_select_limit is used to decide if we are likely to scan the whole table.
  ha_rows m_select_limit;
  /**
    Used to fetch no more than given amount of rows per one
    fetch operation of server side cursor.
    The value is checked in end_send and end_send_group in fashion, similar
    to offset_limit_cnt:
      - fetch_limit= HA_POS_ERROR if there is no cursor.
      - when we open a cursor, we set fetch_limit to 0,
      - on each fetch iteration we add num_rows to fetch to fetch_limit
  */
  ha_rows  fetch_limit;

  /**
     Minimum number of matches that is needed to use JT_FT access.
     @see optimize_fts_limit_query
  */
  ha_rows  min_ft_matches;

  /* Finally picked QEP. This is result of join optimization */
  POSITION *best_positions;

/******* Join optimization state members start *******/

  /* Current join optimization state */
  POSITION *positions;

  /* We also maintain a stack of join optimization states in * join->positions[] */
/******* Join optimization state members end *******/


  Next_select_func first_select;
  /**
    The cost of best complete join plan found so far during optimization,
    after optimization phase - cost of picked join order (not taking into
    account the changes made by test_if_skip_sort_order()).
  */
  double   best_read;
  /**
    The estimated row count of the plan with best read time (see above).
  */
  ha_rows  best_rowcount;
  List<Item> *fields;
  List<Cached_item> group_fields, group_fields_cache;
  THD      *thd;
  Item_sum  **sum_funcs, ***sum_funcs_end;
  /** second copy of sumfuncs (for queries with 2 temporary tables */
  Item_sum  **sum_funcs2, ***sum_funcs_end2;
  ulonglong  select_options;
  select_result *result;
  TMP_TABLE_PARAM tmp_table_param;
  MYSQL_LOCK *lock;
  /// unit structure (with global parameters) for this select
  SELECT_LEX_UNIT *unit;
  /// select that processed
  SELECT_LEX *select_lex;
  /**
    TRUE <=> optimizer must not mark any table as a constant table.
    This is needed for subqueries in form "a IN (SELECT .. UNION SELECT ..):
    when we optimize the select that reads the results of the union from a
    temporary table, we must not mark the temp. table as constant because
    the number of rows in it may vary from one subquery execution to another.
  */
  bool no_const_tables;

  ROLLUP rollup;                ///< Used with rollup

  bool select_distinct;             ///< Set if SELECT DISTINCT
  /**
    If we have the GROUP BY statement in the query,
    but the group_list was emptied by optimizer, this
    flag is TRUE.
    It happens when fields in the GROUP BY are from
    constant table
  */
  bool group_optimized_away;

  /*
    simple_xxxxx is set if ORDER/GROUP BY doesn't include any references
    to other tables than the first non-constant table in the JOIN.
    It's also set if ORDER/GROUP BY is empty.
    Used for deciding for or against using a temporary table to compute
    GROUP/ORDER BY.
  */
  bool simple_order, simple_group;

  /*
    ordered_index_usage is set if an ordered index access
    should be used instead of a filesort when computing
    ORDER/GROUP BY.
  */
  enum
  {
    ordered_index_void,       // No ordered index avail.
    ordered_index_group_by,   // Use index for GROUP BY
    ordered_index_order_by    // Use index for ORDER BY
  } ordered_index_usage;

  /**
    Is set only in case if we have a GROUP BY clause
    and no ORDER BY after constant elimination of 'order'.
  */
  bool no_order;
  /** Is set if we have a GROUP BY and we have ORDER BY on a constant. */
  bool          skip_sort_order;

  bool need_tmp;
  int hidden_group_field_count;

  Key_use_array keyuse;

  List<Item> all_fields; ///< to store all expressions used in query
  ///Above list changed to use temporary table
  List<Item> tmp_all_fields1, tmp_all_fields2, tmp_all_fields3;
  ///Part, shared with list above, emulate following list
  List<Item> tmp_fields_list1, tmp_fields_list2, tmp_fields_list3;
  List<Item> &fields_list; ///< hold field list passed to mysql_select
  List<Item> procedure_fields_list;
  int error; ///< set in optimize(), exec(), prepare_result()    
  /**
    ORDER BY and GROUP BY lists, to transform with prepare,optimize and exec
  */
  ORDER_with_src order, group_list;

  /**
    Buffer to gather GROUP BY, ORDER BY and DISTINCT QEP details for EXPLAIN
  */
  Explain_format_flags explain_flags;

  /**
    JOIN::having is initially equal to select_lex->having, but may
    later be changed by optimizations performed by JOIN.
    The relationship between the JOIN::having condition and the
    associated variable select_lex->having_value is so that
    having_value can be:
     - COND_UNDEF if a having clause was not specified in the query or
       if it has not been optimized yet
     - COND_TRUE if the having clause is always true, in which case
       JOIN::having is set to NULL.
     - COND_FALSE if the having clause is impossible, in which case
       JOIN::having is set to NULL
     - COND_OK otherwise, meaning that the having clause needs to be
       further evaluated
    All of the above also applies to the conds/select_lex->cond_value
    pair.
  */
  Item       *conds;                      ///< The where clause item tree
  Item       *having;                     ///< The having clause item tree
  Item       *having_for_explain;    ///< Saved optimized HAVING for EXPLAIN
  TABLE_LIST *tables_list;           ///<hold 'tables' parameter of mysql_select
  List<TABLE_LIST> *join_list;       ///< list of joined tables in reverse order
  COND_EQUAL *cond_equal;
  /*
    Join tab to return to. Points to an element of join->join_tab array, or to
    join->join_tab[-1].
    This is used at execution stage to shortcut join enumeration. Currently
    shortcutting is done to handle outer joins or handle semi-joins with
    FirstMatch strategy.
  */
  JOIN_TAB *return_tab;

  /*
    Used pointer reference for this select.
    select_lex->ref_pointer_array contains five "slices" of the same length:
    |========|========|========|========|========|
     ref_ptrs items0   items1   items2   items3
   */
  Ref_ptr_array ref_ptrs;
  // Copy of the initial slice above, to be used with different lists
  Ref_ptr_array items0, items1, items2, items3;
  // Used by rollup, to restore ref_ptrs after overwriting it.
  Ref_ptr_array current_ref_ptrs;
};  
      
```

#2.class ORDER_with_src
```cpp
  /**
    Wrapper for ORDER* pointer to trace origins of ORDER list

    As far as ORDER is just a head object of ORDER expression
    chain, we need some wrapper object to associate flags with
    the whole ORDER list.
  */
  class ORDER_with_src
  {
    /**
      Private empty class to implement type-safe NULL assignment

      This private utility class allows us to implement a constructor
      from NULL and only NULL (or 0 -- this is the same thing) and
      an assignment operator from NULL.
      Assignments from other pointers still prohibited since other
      pointer types are incompatible with the "null" type, and the
      casting is impossible outside of ORDER_with_src class, since
      the "null" type is private.
    */
    struct null {};

  public:
    ORDER *order;  //< ORDER expression that we are wrapping with this class
    Explain_sort_clause src; //< origin of order list

  private:
    int flags; //< bitmap of Explain_sort_property
  };    
```