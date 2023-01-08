#1.class VirtualColumnBase

```cpp
/*! \brief A column defined by an expression (including a subquery) or
 * encapsulating a PhysicalColumn VirtualColumn is associated with an
 * core::MultiIndex object and cannot exist without it. Values contained in
 * VirtualColumn object may not exist physically, they can be computed on
 * demand.
 *
 */

class VirtualColumnBase : public core::Column {
 public:
  struct VarMap {
    VarMap(core::VarID v, core::JustATable *t, int d)
        : var_id(v), col_ndx(v.col < 0 ? -v.col - 1 : v.col), dim(d), just_a_table(t->shared_from_this()) {}
    core::VarID var_id;  // variable identified by table alias and column number
    int col_ndx;         // column index (not negative)
    int dim;             // dimension in multiindex corresponding to the alias
    core::JustATable *just_a_table_ptr;
    std::weak_ptr<core::JustATable> just_a_table;  // table corresponding to the alias
  };

 protected:
  core::MultiIndex *multi_index_;
  core::Transaction *conn_info_;
  std::vector<VarMap> var_map_;
  core::MysqlExpression::SetOfVars params_;  // parameters - columns from tables not
                                             // present in the local multiindex

  mutable std::shared_ptr<core::ValueOrNull> last_val_;
  //! for caching, the first time evaluation is obligatory e.g. because a
  //! parameter has been changed

  mutable bool first_eval_;

  int dim_;  // valid only for SingleColumn and for ExpressionColumn if based on
             // a single table only
  // then this an easily accessible copy of var_map_[0]._dim. Otherwise it should
  // be -1

  //////////// Local statistics (set by history) ///////////////
  int64_t vc_min_val_;  // int64_t for ints/dec, *(double*)& for floats
  int64_t vc_max_val_;
  bool vc_nulls_possible_;  // false => no nulls, except of outer join ones (to
                            // be checked in multiindex)
  int64_t vc_dist_vals_;    // upper approximation of non-null distinct vals, or
                            // common::NULL_VALUE_64 for no approximation
  bool nulls_only_;         // only nulls are present
};
  
```