#1.class QEP_shared_owner

```cpp
/// Owner of a QEP_shared; parent of JOIN_TAB and QEP_TAB.
class QEP_shared_owner
{
public:
  QEP_shared_owner() : m_qs(NULL) {}

  /// Instructs to share the QEP_shared with another owner
  void share_qs(QEP_shared_owner *other) { other->set_qs(m_qs); }
  void set_qs(QEP_shared *q) { assert(!m_qs); m_qs= q; }

  // Getters/setters forwarding to QEP_shared:

  JOIN *join() const { return m_qs->join(); }
  void set_join(JOIN *j) { return m_qs->set_join(j); }
  plan_idx idx() const { return m_qs->idx(); }
  void set_idx(plan_idx i) { return m_qs->set_idx(i); }
  TABLE *table() const { return m_qs->table(); }
  POSITION *position() const { return m_qs->position(); }
  void set_position(POSITION *p) { return m_qs->set_position(p); }
  Semijoin_mat_exec *sj_mat_exec() const { return m_qs->sj_mat_exec(); }
  void set_sj_mat_exec(Semijoin_mat_exec *s) { return m_qs->set_sj_mat_exec(s); }
  plan_idx first_sj_inner() const { return m_qs->first_sj_inner(); }
  plan_idx last_sj_inner() const { return m_qs->last_sj_inner(); }
  plan_idx first_inner() const { return m_qs->first_inner(); }
  plan_idx last_inner() const { return m_qs->last_inner(); }
  plan_idx first_upper() const { return m_qs->first_upper(); }
  void set_first_inner(plan_idx i) { return m_qs->set_first_inner(i); }
  void set_last_inner(plan_idx i) { return m_qs->set_last_inner(i); }
  void set_first_sj_inner(plan_idx i) { return m_qs->set_first_sj_inner(i); }
  void set_last_sj_inner(plan_idx i) { return m_qs->set_last_sj_inner(i); }
  void set_first_upper(plan_idx i) { return m_qs->set_first_upper(i); }
  TABLE_REF &ref() const { return m_qs->ref(); }
  uint index() const { return m_qs->index(); }
  void set_index(uint i) { return m_qs->set_index(i); }
  enum join_type type() const { return m_qs->type(); }
  void set_type(enum join_type t) { return m_qs->set_type(t); }
  Item *condition() const { return m_qs->condition(); }
  void set_condition(Item *to) { return m_qs->set_condition(to); }
  key_map &keys() { return m_qs->keys(); }
  ha_rows records() const { return m_qs->records(); }
  void set_records(ha_rows r) { return m_qs->set_records(r); }
  QUICK_SELECT_I *quick() const { return m_qs->quick(); }
  void set_quick(QUICK_SELECT_I *q) { return m_qs->set_quick(q); }
  table_map prefix_tables() const { return m_qs->prefix_tables(); }
  table_map added_tables() const { return m_qs->added_tables(); }
  Item_func_match *ft_func() const { return m_qs->ft_func(); }
  void set_ft_func(Item_func_match *f) { return m_qs->set_ft_func(f); }
  void set_prefix_tables(table_map prefix_tables, table_map prev_tables)
  { return m_qs->set_prefix_tables(prefix_tables, prev_tables); }
  void add_prefix_tables(table_map tables)
  { return m_qs->add_prefix_tables(tables); }
  bool is_single_inner_of_semi_join() const
  { return m_qs->is_single_inner_of_semi_join(); }
  bool is_inner_table_of_outer_join() const
  { return m_qs->is_inner_table_of_outer_join(); }
  bool is_first_inner_for_outer_join() const
  { return m_qs->is_first_inner_for_outer_join(); }
  bool is_single_inner_for_outer_join() const
  { return m_qs->is_single_inner_of_outer_join(); }

  bool has_guarded_conds() const
  { return ref().has_guarded_conds(); }
  bool and_with_condition(Item *tmp_cond);

  void qs_cleanup();

protected:
  QEP_shared *m_qs; // qs stands for Qep_Shared
};

```