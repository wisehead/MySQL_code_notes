#1.class QEP_TAB

```cpp
class QEP_TAB : public Sql_alloc, public QEP_shared_owner
{
public:
  QEP_TAB() :
    QEP_shared_owner(),
    table_ref(NULL),
    flush_weedout_table(NULL),
    check_weed_out_table(NULL),
    firstmatch_return(NO_PLAN_IDX),
    loosescan_key_len(0),
    loosescan_buf(NULL),
    match_tab(NO_PLAN_IDX),
    found_match(false),
    found(false),
    not_null_compl(false),
    first_unmatched(NO_PLAN_IDX),
    materialized(false),
    materialize_table(NULL),
    read_first_record(NULL),
    next_select(NULL),
    read_record(),
    save_read_first_record(NULL),
    save_read_record(NULL),
    used_null_fields(false),
    used_uneven_bit_fields(false),
    keep_current_rowid(false),
    copy_current_rowid(NULL),
    distinct(false),
    not_used_in_distinct(false),
    cache_idx_cond(NULL),
    having(NULL),
    op(NULL),
    tmp_table_param(NULL),
    filesort(NULL),
    fields(NULL),
    all_fields(NULL),
    ref_array(NULL),
    send_records(0),
    quick_traced_before(false),
    m_condition_optim(NULL),
    m_quick_optim(NULL),
    m_keyread_optim(false)
  {
    /**
       @todo Add constructor to READ_RECORD.
       All users do init_read_record(), which does memset(),
       rather than invoking a constructor.
    */
  }

  /// Initializes the object from a JOIN_TAB
  void init(JOIN_TAB *jt);
  // Cleans up.
  void cleanup();

  // Getters and setters

  Item *condition_optim() const { return m_condition_optim; }
  QUICK_SELECT_I *quick_optim() const { return m_quick_optim; }
  void set_quick_optim() { m_quick_optim= quick(); }
  void set_condition_optim() { m_condition_optim= condition(); }
  bool keyread_optim() const { return m_keyread_optim; }
  void set_keyread_optim()
  {
    if (table())
      m_keyread_optim= table()->key_read;
  }

  void set_table(TABLE *t)
  {
    m_qs->set_table(t);
    if (t)
      t->reginfo.qep_tab= this;
  }

  /// @returns semijoin strategy for this table.
  uint get_sj_strategy() const;

  /// Return true if join_tab should perform a FirstMatch action
  bool do_firstmatch() const { return firstmatch_return != NO_PLAN_IDX; }

  /// Return true if join_tab should perform a LooseScan action
  bool do_loosescan() const { return loosescan_key_len; }

  /// Return true if join_tab starts a Duplicate Weedout action
  bool starts_weedout() const { return flush_weedout_table; }

  /// Return true if join_tab finishes a Duplicate Weedout action
  bool finishes_weedout() const { return check_weed_out_table; }

  bool prepare_scan();

  /**
    A helper function that allocates appropriate join cache object and
    sets next_select function of previous tab.
  */
  void init_join_cache(JOIN_TAB *join_tab);

  /**
     @returns query block id for an inner table of materialized semi-join, and
              0 for all other tables.
     @note implementation is not efficient (loops over all tables) - use this
     function only in EXPLAIN.
  */
  uint sjm_query_block_id() const;

  /// @returns whether this is doing QS_DYNAMIC_RANGE
  bool dynamic_range() const
  {
    if (!position())
      return false; // tmp table
    return read_first_record == join_init_quick_read_record;
  }

  bool use_order() const; ///< Use ordering provided by chosen index?
  bool sort_table();
  bool remove_duplicates();

  inline bool skip_record(THD *thd, bool *skip_record_arg)
  {
    *skip_record_arg= condition() ? condition()->val_int() == FALSE : FALSE;
    return thd->is_error();
  }

  /**
     Used to begin a new execution of a subquery. Necessary if this subquery
     has done a filesort which which has cleared condition/quick.
  */
  void restore_quick_optim_and_condition()
  {
    if (m_condition_optim)
      set_condition(m_condition_optim);
    if (m_quick_optim)
      set_quick(m_quick_optim);
  }

  void pick_table_access_method(const JOIN_TAB *join_tab);
  void set_pushed_table_access_method(void);
  void push_index_cond(const JOIN_TAB *join_tab,
                       uint keyno, Opt_trace_object *trace_obj);

  /// @return the index used for a table in a QEP
  uint effective_index() const;

  bool pfs_batch_update(JOIN *join);

public:
  /// Pointer to table reference
  TABLE_LIST *table_ref;

  /* Variables for semi-join duplicate elimination */
  SJ_TMP_TABLE *flush_weedout_table;
  SJ_TMP_TABLE *check_weed_out_table;

  /*
    If set, means we should stop join enumeration after we've got the first
    match and return to the specified join tab. May be PRE_FIRST_PLAN_IDX
    which means stopping join execution after the first match.
  */
  plan_idx firstmatch_return;

  /*
    Length of key tuple (depends on #keyparts used) to store in loosescan_buf.
    If zero, means that loosescan is not used.
  */
  uint loosescan_key_len;

  /* Buffer to save index tuple to be able to skip duplicates */
  uchar *loosescan_buf;

  /*
    If doing a LooseScan, this QEP is the first (i.e.  "driving")
    QEP_TAB, and match_tab points to the last QEP_TAB handled by the strategy.
    match_tab->found_match should be checked to see if the current value group
    had a match.
    If doing a FirstMatch, check this QEP_TAB to see if there is a match.
    Unless the FirstMatch performs a "split jump", this is equal to the
    current QEP_TAB.
  */
  plan_idx match_tab;

  /*
    Used by FirstMatch and LooseScan. TRUE <=> there is a matching
    record combination
  */
  bool found_match;

  /**
    Used to decide whether an inner table of an outer join should produce NULL
    values. If it is true after a call to evaluate_join_record(), the join
    condition has been satisfied for at least one row from the inner
    table. This member is not really manipulated by this class, see sub_select
    for details on its use.
  */
  bool found;

  /**
    This member is true as long as we are evaluating rows from the inner
    tables of an outer join. If none of these rows satisfy the join condition,
    we generated NULL-complemented rows and set this member to false. In the
    meantime, the value may be read by triggered conditions, see
    Item_func_trig_cond::val_int().
  */
  bool not_null_compl;

  plan_idx first_unmatched; /**< used for optimization purposes only   */

  /// For a materializable derived or SJ table: true if has been materialized
  bool materialized;

  READ_RECORD::Setup_func materialize_table;
  /**
     Initialize table for reading and fetch the first row from the table. If
     table is a materialized derived one, function must materialize it with
     prepare_scan().
  */
  READ_RECORD::Setup_func read_first_record;
  Next_select_func next_select;
  READ_RECORD read_record;
  /*
    The following two fields are used for a [NOT] IN subquery if it is
    executed by an alternative full table scan when the left operand of
    the subquery predicate is evaluated to NULL.
  */
  READ_RECORD::Setup_func save_read_first_record;/* to save read_first_record */
  READ_RECORD::Read_func save_read_record;/* to save read_record.read_record */

  // join-cache-related members
  bool          used_null_fields;
  bool          used_uneven_bit_fields;

  /*
    Used by DuplicateElimination. tab->table->ref must have the rowid
    whenever we have a current record. copy_current_rowid needed because
    we cannot bind to the rowid buffer before the table has been opened.
  */
  bool keep_current_rowid;
  st_cache_field *copy_current_rowid;

  /** TRUE <=> remove duplicates on this table. */
  bool distinct;

  bool not_used_in_distinct;

  /// Index condition for BKA access join
  Item *cache_idx_cond;

  /** HAVING condition for checking prior saving a record into tmp table*/
  Item *having;

  QEP_operation *op;

  /* Tmp table info */
  Temp_table_param *tmp_table_param;

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

  /**
    Used for QS_DYNAMIC_RANGE, i.e., "Range checked for each record".
    Used by optimizer tracing to decide whether or not dynamic range
    analysis of this select has been traced already. If optimizer
    trace option DYNAMIC_RANGE is enabled, range analysis will be
    traced with different ranges for every record to the left of this
    table in the join. If disabled, range analysis will only be traced
    for the first range.
  */
  bool quick_traced_before;

  /// @See m_quick_optim
  Item          *m_condition_optim;

  /**
     m_quick is the quick "to be used at this stage of execution".
     It can happen that filesort uses the quick (produced by the optimizer) to
     produce a sorted result, then the read of this result has to be done
     without "quick", so we must reset m_quick to NULL, but we want to delay
     freeing of m_quick or it would close the filesort's result and the table
     prematurely.
     In that case, we move m_quick to m_quick_optim (=> delay deletion), reset
     m_quick to NULL (read of filesort's result will be without quick); if
     this is a subquery which is later executed a second time,
     QEP_TAB::reset() will restore the quick from m_quick_optim into m_quick.
     quick_optim stands for "the quick decided by the optimizer".
     EXPLAIN reads this member and m_condition_optim; so if you change them
     after exposing the plan (setting plan_state), do it with the
     LOCK_query_plan mutex.
  */
  QUICK_SELECT_I *m_quick_optim;

  /**
     True if only index is going to be read for this table. This is the
     optimizer's decision.
  */
  bool m_keyread_optim;

  QEP_TAB(const QEP_TAB&);                      // not defined
  QEP_TAB& operator=(const QEP_TAB&);           // not defined
};


```