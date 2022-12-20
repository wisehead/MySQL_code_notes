#1.st_join_table(JOIN_TAB)

```cpp
typedef struct st_join_table : public Sql_alloc
{
  st_join_table();

  table_map prefix_tables() const { return prefix_tables_map; }

  table_map added_tables() const { return added_tables_map; }

  /**
    Set available tables for a table in a join plan.

    @param prefix_tables: Set of tables available for this plan
    @param prev_tables: Set of tables available for previous table, used to
                        calculate set of tables added for this table.
  */
  void set_prefix_tables(table_map prefix_tables, table_map prev_tables)
  {
    prefix_tables_map= prefix_tables;
    added_tables_map= prefix_tables & ~prev_tables;
  }

  /**
    Add an available set of tables for a table in a join plan.

    @param tables: Set of tables added for this table in plan.
  */
  void add_prefix_tables(table_map tables)
  { prefix_tables_map|= tables; added_tables_map|= tables; }

  /// Return true if join_tab should perform a FirstMatch action
  bool do_firstmatch() const { return firstmatch_return; }

  /// Return true if join_tab should perform a LooseScan action
  bool do_loosescan() const { return loosescan_key_len; }

  /// Return true if join_tab starts a Duplicate Weedout action
  bool starts_weedout() const { return flush_weedout_table; }

  /// Return true if join_tab finishes a Duplicate Weedout action
  bool finishes_weedout() const { return check_weed_out_table; }

  TABLE         *table;
  POSITION      *position;      /**< points into best_positions array        */
  Key_use       *keyuse;        /**< pointer to first used key               */
  SQL_SELECT    *select;
private:
  Item          *m_condition;   /**< condition for this join_tab             */
public:
  QUICK_SELECT_I *quick;
  Item         **on_expr_ref;   /**< pointer to the associated on expression */
  COND_EQUAL    *cond_equal;    /**< multiple equalities for the on expression*/
  st_join_table *first_inner;   /**< first inner table for including outerjoin*/
  bool           found;         /**< true after all matches or null complement*/
  bool           not_null_compl;/**< true before null complement is added    */
  /// For a materializable derived or SJ table: true if has been materialized
  bool           materialized;
  st_join_table *last_inner;    /**< last table table for embedding outer join*/
  st_join_table *first_upper;  /**< first inner table for embedding outer join*/
  st_join_table *first_unmatched; /**< used for optimization purposes only   */
  /*
    The value of m_condition before we've attempted to do Index Condition
    Pushdown. We may need to restore everything back if we first choose one
    index but then reconsider (see test_if_skip_sort_order() for such
    scenarios).
    NULL means no index condition pushdown was performed.
  */
  Item          *pre_idx_push_cond;

  /* Special content for EXPLAIN 'Extra' column or NULL if none */
  Extra_tag     info;
  /*
    Bitmap of TAB_INFO_* bits that encodes special line for EXPLAIN 'Extra'
    column, or 0 if there is no info.
  */
  uint          packed_info;

  READ_RECORD::Setup_func materialize_table;
  /**
     Initialize table for reading and fetch the first row from the table. If
     table is a materialized derived one, function must materialize it with
     prepare_scan().
  */
  READ_RECORD::Setup_func read_first_record;
  Next_select_func next_select;
  READ_RECORD   read_record;
  /*
    The following two fields are used for a [NOT] IN subquery if it is
    executed by an alternative full table scan when the left operand of
    the subquery predicate is evaluated to NULL.
  */
  READ_RECORD::Setup_func save_read_first_record;/* to save read_first_record */
  READ_RECORD::Read_func save_read_record;/* to save read_record.read_record */
  /**
    Struct needed for materialization of semi-join. Set for a materialized
    temporary table, and NULL for all other join_tabs (except when
    materialization is in progress, @see join_materialize_semijoin()).
  */
  Semijoin_mat_exec *sj_mat_exec;
  double    worst_seeks;
  /** Keys with constant part. Subset of keys. */
  key_map   const_keys;
  key_map   checked_keys;           /**< Keys checked */
  key_map   needed_reg;
  key_map       keys;                           /**< all keys with can be used */
  /**
    Used to avoid repeated range analysis for the same key in
    test_if_skip_sort_order(). This would otherwise happen if the best
    range access plan found for a key is turned down.
    quick_order_tested is cleared every time the select condition for
    this JOIN_TAB changes since a new condition may give another plan
    and cost from range analysis.
   */
  key_map       quick_order_tested;

  /* Either #rows in the table or 1 for const table.  */
  ha_rows   records;
  /*
    Number of records that will be scanned (yes scanned, not returned) by the
    best 'independent' access method, i.e. table scan or QUICK_*_SELECT)
  */
  ha_rows       found_records;
  /*
    Cost of accessing the table using "ALL" or range/index_merge access
    method (but not 'index' for some reason), i.e. this matches method which
    E(#records) is in found_records.
  */
  ha_rows       read_time;
  /**
    The set of tables that this table depends on. Used for outer join and
    straight join dependencies.
  */
  table_map     dependent;
  /**
    The set of tables that are referenced by key from this table.
  */
  table_map     key_dependent;
private:
  /**
    The set of all tables available in the join prefix for this table,
    including the table handled by this JOIN_TAB.
  */
  table_map     prefix_tables_map;
  /**
    The set of tables added for this table, compared to the previous table
    in the join prefix.
  */
  table_map     added_tables_map;
public:
  /// ID of index used for index scan or semijoin LooseScan
  uint      index;
  uint      used_fields,used_fieldlength,used_blobs;
  uint          used_null_fields;
  uint          used_rowid_fields;
  uint          used_uneven_bit_fields;
  enum quick_type use_quick;
  enum join_type type;
  bool          not_used_in_distinct;
  /*
    If it's not 0 the number stored this field indicates that the index
    scan has been chosen to access the table data and we expect to scan
    this number of rows for the table.
  */
  ha_rows       limit;
  TABLE_REF ref;
  /**
    Join buffering strategy.
    After optimization it contains chosen join buffering strategy (if any).
   */
  uint          use_join_cache;
  QEP_operation *op;
  /*
    Index condition for BKA access join
  */
  Item          *cache_idx_cond;
  SQL_SELECT    *cache_select;
  JOIN      *join;

  /* SemiJoinDuplicateElimination variables: */
  /*
    Embedding SJ-nest (may be not the direct parent), or NULL if none.
    This variable holds the result of table pullout.
  */
  TABLE_LIST    *emb_sj_nest;

  /**
    Boundaries of semijoin inner tables around this table. Valid only once
    final QEP has been chosen. Depending on the strategy, they may define an
    interval (all tables inside are inner of a semijoin) or
    not. last_sj_inner_tab is not set for Duplicates Weedout.
  */
  struct st_join_table *first_sj_inner_tab;
  struct st_join_table *last_sj_inner_tab;

  /* Variables for semi-join duplicate elimination */
  SJ_TMP_TABLE  *flush_weedout_table;
  SJ_TMP_TABLE  *check_weed_out_table;

  /*
    If set, means we should stop join enumeration after we've got the first
    match and return to the specified join tab. May point to
    join->join_tab[-1] which means stop join execution after the first
    match.
  */
  struct st_join_table  *firstmatch_return;

  /*
    Length of key tuple (depends on #keyparts used) to store in loosescan_buf.
    If zero, means that loosescan is not used.
  */
  uint loosescan_key_len;

  /* Buffer to save index tuple to be able to skip duplicates */
  uchar *loosescan_buf;

  /*
    If doing a LooseScan, this join tab is the first (i.e.  "driving") join
    tab, and match_tab points to the last join tab handled by the strategy.
    match_tab->found_match should be checked to see if the current value group
    had a match.
    If doing a FirstMatch, check this join tab to see if there is a match.
    Unless the FirstMatch performs a "split jump", this is equal to the
    current join_tab.
  */
  struct st_join_table *match_tab;
  /*
    Used by FirstMatch and LooseScan. TRUE <=> there is a matching
    record combination
  */
  bool found_match;

  /*
    Used by DuplicateElimination. tab->table->ref must have the rowid
    whenever we have a current record. copy_current_rowid needed because
    we cannot bind to the rowid buffer before the table has been opened.
  */
  int  keep_current_rowid;
  st_cache_field *copy_current_rowid;

  /* NestedOuterJoins: Bitmap of nested joins this table is part of */
  nested_join_map embedding_map;

  /* Tmp table info */
  TMP_TABLE_PARAM *tmp_table_param;

  /* Sorting related info */
  Filesort *filesort;

  /**
    List of topmost expressions in the select list. The *next* JOIN TAB
    in the plan should use it to obtain correct values. Same applicable to
    all_fields. These lists are needed because after tmp tables functions
    will be turned to fields. These variables are pointing to
    tmp_fields_list[123]. Valid only for tmp tables and the last non-tmp
    table in the query plan.
    @see JOIN::make_tmp_tables_info()
  */
  List<Item> *fields;
  /** List of all expressions in the select list */
  List<Item> *all_fields;
  /*
    Pointer to the ref array slice which to switch to before sending
    records. Valid only for tmp tables.
  */
  Ref_ptr_array *ref_array;

  /** Number of records saved in tmp table */
  ha_rows send_records;

  /** HAVING condition for checking prior saving a record into tmp table*/
  Item *having;

  /** TRUE <=> remove duplicates on this table. */
  bool distinct;
} JOIN_TAB;            
```