#1.class Descriptor

```cpp
class Descriptor {
 public:
  common::Operator op;
  CQTerm attr;  // descriptor is usually "attr op val1 [val2]", e.g. "a = 7", "a
                // BETWEEN 8 AND 12"
  CQTerm val1;
  CQTerm val2;

  common::LogicalOperator lop;  // OR is not implemented on some lower levels!
                                // Only valid in HAVING tree.
  bool sharp;                   // used to indicate that BETWEEN contains sharp inequalities
  bool encoded;
  bool done;
  double evaluation;  // approximate weight ("hardness") of the condition;
                      // execution order is based on it
  bool delayed;       // descriptor is delayed (usually because of outer joins) tbd.
                      // after joins
  TempTable *table;
  DescTree *tree;
  DimensionVector left_dims;
  DimensionVector right_dims;
  int parallsize = 0;
  std::vector<common::RoughSetValue> rvs;  // index corresponding threadid
  common::RoughSetValue rv;                // rough evaluation of descriptor (accumulated or used locally)
  char like_esc;                           // nonstandard LIKE escape character
  std::mutex mtx;
  CondType cond_type = CondType::UNKOWN_COND;
...
...
 private:
  /*! \brief Checks condition for set operator, e.g., <ALL
   * \pre LockSourcePacks done externally.
   * \param mit - iterator on MultiIndex
   * \param op - operator to check
   * \return bool
   */
  //! make the type of to_be_casted to be comparable to attr.vc by wrapping
  //! to_be_casted in a vcolumn::TypeCastColumn
  DescriptorJoinType desc_t;
  DTCollation collation;

 public:
  bool null_after_simplify;  // true if Simplify set common::Operator::O_FALSE because of
                             // nullptr
};  
```