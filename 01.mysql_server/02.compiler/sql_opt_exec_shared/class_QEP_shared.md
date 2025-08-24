#1.class QEP_shared

```cpp
/// Holds members common to JOIN_TAB and QEP_TAB.
class QEP_shared : public Sql_alloc
{
public:
  QEP_shared() :
    m_join(NULL),
    m_idx(NO_PLAN_IDX),
    m_table(NULL),
    m_position(NULL),
    m_sj_mat_exec(NULL),
    m_first_sj_inner(NO_PLAN_IDX),
    m_last_sj_inner(NO_PLAN_IDX),
    m_first_inner(NO_PLAN_IDX),
    m_last_inner(NO_PLAN_IDX),
    m_first_upper(NO_PLAN_IDX),
    m_ref(),
    m_index(0),
    m_type(JT_UNKNOWN),
    m_condition(NULL),
    m_keys(),
    m_records(0),
    m_quick(NULL),
    prefix_tables_map(0),
    added_tables_map(0),
    m_ft_func(NULL)
    {}

  /*
    Simple getters and setters. They are public. However, this object is
    protected in QEP_shared_owner, so only that class and its children
    (JOIN_TAB, QEP_TAB) can access the getters and setters.
  */

  JOIN *join() const { return m_join; }
  void set_join(JOIN *j) { m_join= j; }
  plan_idx idx() const
  {
    assert(m_idx >= 0);                    // Index must be valid
    return m_idx;
  }
  void set_idx(plan_idx i)
  {
    assert(m_idx == NO_PLAN_IDX);      // Index should not change in lifetime
    m_idx= i;
  }
  TABLE *table() const { return m_table; }
  void set_table(TABLE *t) { m_table= t; }
  POSITION *position() const { return m_position; }
  void set_position(POSITION *p) { m_position= p; }
  Semijoin_mat_exec *sj_mat_exec() const { return m_sj_mat_exec; }
  void set_sj_mat_exec(Semijoin_mat_exec *s) { m_sj_mat_exec= s; }
  plan_idx first_sj_inner() { return m_first_sj_inner; }
  plan_idx last_sj_inner() { return m_last_sj_inner; }
  plan_idx first_inner() { return m_first_inner; }
  void set_first_inner(plan_idx i) { m_first_inner= i; }
  void set_last_inner(plan_idx i) { m_last_inner= i; }
  void set_first_sj_inner(plan_idx i) { m_first_sj_inner= i; }
  void set_last_sj_inner(plan_idx i) { m_last_sj_inner= i; }
  void set_first_upper(plan_idx i) { m_first_upper= i; }
  plan_idx last_inner() { return m_last_inner; }
  plan_idx first_upper() { return m_first_upper; }
  TABLE_REF &ref() { return m_ref; }
  uint index() const { return m_index; }
  void set_index(uint i) { m_index= i; }
  enum join_type type() const { return m_type; }
  void set_type(enum join_type t) { m_type= t; }
  Item *condition() const { return m_condition; }
  void set_condition(Item *c) { m_condition= c; }
  key_map &keys() { return m_keys; }
  ha_rows records() const { return m_records; }
  void set_records(ha_rows r) { m_records= r; }
  QUICK_SELECT_I *quick() const { return m_quick; }
  void set_quick(QUICK_SELECT_I *q) { m_quick= q; }
  table_map prefix_tables() const { return prefix_tables_map; }
  table_map added_tables() const { return added_tables_map; }
  Item_func_match *ft_func() const { return m_ft_func; }
  void set_ft_func(Item_func_match *f) { m_ft_func= f; }

  // More elaborate functions:

  /**
    Set available tables for a table in a join plan.

    @param prefix_tables_arg: Set of tables available for this plan
    @param prev_tables_arg: Set of tables available for previous table, used to
                            calculate set of tables added for this table.
  */
  void set_prefix_tables(table_map prefix_tables_arg, table_map prev_tables_arg)
  {
    prefix_tables_map= prefix_tables_arg;
    added_tables_map= prefix_tables_arg & ~prev_tables_arg;
  }

  /**
    Add an available set of tables for a table in a join plan.

    @param tables: Set of tables added for this table in plan.
  */
  void add_prefix_tables(table_map tables)
  { prefix_tables_map|= tables; added_tables_map|= tables; }

  bool is_first_inner_for_outer_join() const
  {
    return m_first_inner == m_idx;
  }

  bool is_inner_table_of_outer_join() const
  {
    return m_first_inner != NO_PLAN_IDX;
  }
  bool is_single_inner_of_semi_join() const
  {
    return m_first_sj_inner == m_idx && m_last_sj_inner == m_idx;
  }
  bool is_single_inner_of_outer_join() const
  {
    return m_first_inner == m_idx && m_last_inner == m_idx;
  }

private:

  JOIN	*m_join;

  /**
     Index of structure in array:
     - NO_PLAN_IDX if before get_best_combination()
     - index of pointer to this JOIN_TAB, in JOIN::best_ref array
     - index of this QEP_TAB, in JOIN::qep array.
  */
  plan_idx  m_idx;

  /// Corresponding table. Might be an internal temporary one.
  TABLE *m_table;

  /// Points into best_positions array. Includes cost info.
  POSITION      *m_position;

  /*
    semijoin-related members.
  */

  /**
    Struct needed for materialization of semi-join. Set for a materialized
    temporary table, and NULL for all other join_tabs (except when
    materialization is in progress, @see join_materialize_semijoin()).
  */
  Semijoin_mat_exec *m_sj_mat_exec;

  /**
    Boundaries of semijoin inner tables around this table. Valid only once
    final QEP has been chosen. Depending on the strategy, they may define an
    interval (all tables inside are inner of a semijoin) or
    not. last_sj_inner is not set for Duplicates Weedout.
  */
  plan_idx m_first_sj_inner, m_last_sj_inner;

  /*
    outer-join-related members.
  */
  plan_idx m_first_inner;   ///< first inner table for including outer join
  plan_idx m_last_inner;    ///< last table table for embedding outer join
  plan_idx m_first_upper;   ///< first inner table for embedding outer join

  /**
     Used to do index-based look up based on a key value.
     Used when we read constant tables, in misc optimization (like
     remove_const()), and in execution.
  */
  TABLE_REF	m_ref;

  /// ID of index used for index scan or semijoin LooseScan
  uint		m_index;

  /// Type of chosen access method (scan, etc).
  enum join_type m_type;

  /**
    Table condition, ie condition to be evaluated for a row from this table.
    Notice that the condition may refer to rows from previous tables in the
    join prefix, as well as outer tables.
  */
  Item          *m_condition;

  /**
     All keys with can be used.
     Used by add_key_field() (optimization time) and execution of dynamic
     range (join_init_quick_record()), and EXPLAIN.
  */
  key_map       m_keys;

  /**
     Either #rows in the table or 1 for const table.
     Used in optimization, and also in execution for FOUND_ROWS().
  */
  ha_rows	m_records;

  /**
     Non-NULL if quick-select used.
     Filled in optimization, used in execution to find rows, and in EXPLAIN.
  */
  QUICK_SELECT_I *m_quick;

  /*
    Maps below are shared because of dynamic range: in execution, it needs to
    know the prefix tables, to find the possible QUICK methods.
  */

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

  /** FT function */
  Item_func_match *m_ft_func;
};

```