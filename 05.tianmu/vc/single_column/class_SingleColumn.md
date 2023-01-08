#1.class SingleColumn

```cpp
/*! \brief A column defined by an expression (including a subquery) or
 * encapsulating a PhysicalColumn SingleColumn is associated with an
 * core::MultiIndex object and cannot exist without it. Values contained in
 * SingleColumn object may not exist physically, they can be computed on demand.
 *
 */
class SingleColumn : public VirtualColumn {
 public:
  core::PhysicalColumn *col_;  //!= nullptr if SingleColumn encapsulates a single
                               //! column only (no expression)
                               //	this an easily accessible copy
                               // var_map_[0].just_a_table->GetColumn(var_map_[0].)
}; 
```