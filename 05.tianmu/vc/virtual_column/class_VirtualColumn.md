#1.class VirtualColumn

```cpp
/*! \brief A column defined by an expression (including a subquery) or
 * encapsulating a PhysicalColumn VirtualColumn is associated with an
 * core::MultiIndex object and cannot exist without it. Values contained in
 * VirtualColumn object may not exist physically, they can be computed on
 * demand.
 *
 */

class VirtualColumn : public VirtualColumnBase {
 public:
  VirtualColumn(core::ColumnType const &col_type, core::MultiIndex *multi_index)
      : VirtualColumnBase(col_type, multi_index), vc_pack_guard_(this) {}
  VirtualColumn(VirtualColumn const &vc) : VirtualColumnBase(vc), vc_pack_guard_(this) {}
  virtual ~VirtualColumn() { vc_pack_guard_.UnlockAll(); }

  void LockSourcePacks(const core::MIIterator &mit) override { vc_pack_guard_.LockPackrow(mit); }
  void UnlockSourcePacks() override { vc_pack_guard_.UnlockAll(); }

 private:
  core::VCPackGuardian vc_pack_guard_;
};
```