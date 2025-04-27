#1.class Optimize_table_order

```cpp
/**
  This class determines the optimal join order for tables within
  a basic query block, ie a query specification clause, possibly extended
  with semi-joined tables from embedded subqueries.

  This class takes as prerequisite a join class where all dependencies among
  tables have been sorted out, all possible access paths have been
  sorted out, and all statistics information has been filled in.

  The class has a sole public function that will calculate the most
  optimal plan based on the inputs and the environment, such as prune level
  and greedy optimizer search depth. For more information, see the
  function headers for the private functions greedy_search(),
  best_extension_by_limited_search() and eq_ref_extension_by_limited_search().
*/

class Optimize_table_order
{
public:
  Optimize_table_order(THD *thd_arg, JOIN *join_arg, TABLE_LIST *sjm_nest_arg)
  : thd(thd_arg), join(join_arg),
    search_depth(determine_search_depth(thd->variables.optimizer_search_depth,
                                        join->tables - join->const_tables)),
    prune_level(thd->variables.optimizer_prune_level),
    cur_embedding_map(0), emb_sjm_nest(sjm_nest_arg),
    excluded_tables((emb_sjm_nest ?
                     (join->all_table_map & ~emb_sjm_nest->sj_inner_tables) : 0) |
                    (join->allow_outer_refs ? 0 : OUTER_REF_TABLE_BIT)),
    has_sj(!(join->select_lex->sj_nests.is_empty() || emb_sjm_nest)),
    test_all_ref_keys(false), found_plan_with_allowed_sj(false)
  {}
  ~Optimize_table_order()
  {}
  /**
    Entry point to table join order optimization.
    For further description, see class header and private function headers.

    @return false if successful, true if error
  */
  bool choose_table_order();

private:
  THD *const thd;            // Pointer to current THD
  JOIN *const join;          // Pointer to the current plan being developed
  const uint search_depth;   // Maximum search depth to apply in greedy search
  const uint prune_level;    // pruning heuristics to be applied
                             // (0 = EXHAUSTIVE, 1 = PRUNE_BY_TIME_OR_ROWS)
  /**
    Bitmap of all join nests embedding the last table appended to the current 
    partial join.
  */
  nested_join_map cur_embedding_map;
  /**
    If non-NULL, we are optimizing a materialized semi-join nest.
    If NULL, we are optimizing a complete join plan.
  */
  const TABLE_LIST *const emb_sjm_nest;
  /**
    When calculating a plan for a materialized semi-join nest,
    best_access_path() needs to know not only the remaining tables within the
    semi-join nest, but also all tables outside of this nest, because there may
    be key references between the semi-join nest and the outside tables
    that should not be considered when materializing the semi-join nest.
    @c excluded_tables tracks these tables.
  */
  const table_map excluded_tables;
  /*
    No need to call advance_sj_state() when
     1) there are no semijoin nests or
     2) we are optimizing a materialized semijoin nest.
  */
  const bool has_sj;

  /**
     If true, find_best_ref() must go through all keys, no shortcutting
     allowed.
  */
  bool test_all_ref_keys;


  /// True if we found a complete plan using only allowed semijoin strategies.
  bool found_plan_with_allowed_sj;

  inline Key_use* find_best_ref(JOIN_TAB  *tab,
                                const table_map remaining_tables,
                                const uint idx,
                                const double prefix_rowcount,
                                bool *found_condition,
                                table_map *ref_depends_map,
                                uint *used_key_parts);
  double calculate_scan_cost(const JOIN_TAB *tab,
                             const uint idx,
                             const Key_use *best_ref,
                             const double prefix_rowcount,
                             const bool found_condition,
                             const bool disable_jbuf,
                             double *rows_after_filtering,
                             Opt_trace_object *trace_access_scan);
  void best_access_path(JOIN_TAB *tab,
                        const table_map remaining_tables,
                        const uint idx, 
                        bool disable_jbuf,
                        const double prefix_rowcount,
                        POSITION *pos);
  bool semijoin_loosescan_fill_driving_table_position(const JOIN_TAB  *s,
                                                      table_map remaining_tables,
                                                      uint      idx,
                                                      POSITION *loose_scan_pos);
  bool check_interleaving_with_nj(JOIN_TAB *next_tab);
  void advance_sj_state(table_map remaining_tables,
                        const JOIN_TAB *tab, uint idx);
  void backout_nj_state(const table_map remaining_tables,
                        const JOIN_TAB *tab);
  void optimize_straight_join(table_map join_tables);
  bool greedy_search(table_map remaining_tables);
  bool best_extension_by_limited_search(table_map remaining_tables,
                                        uint idx,
                                        uint current_search_depth);
  table_map eq_ref_extension_by_limited_search(
                                        table_map remaining_tables,
                                        uint idx,
                                        uint current_search_depth);
  void consider_plan(uint idx, Opt_trace_object *trace_obj);
  bool fix_semijoin_strategies();
  bool semijoin_firstmatch_loosescan_access_paths(
                uint first_tab, uint last_tab, table_map remaining_tables, 
                bool loosescan, bool final,
                double *newcount, double *newcost);
  void semijoin_mat_scan_access_paths(
                uint last_inner_tab, uint last_outer_tab, 
                table_map remaining_tables, TABLE_LIST *sjm_nest, bool final,
                double *newcount, double *newcost);
  void semijoin_mat_lookup_access_paths(
                uint last_inner, TABLE_LIST *sjm_nest,
                double *newcount, double *newcost);
  void semijoin_dupsweedout_access_paths(
                uint first_tab, uint last_tab, 
                table_map remaining_tables, 
                double *newcount, double *newcost);

  static uint determine_search_depth(uint search_depth, uint table_count);
};


```