#1.struct CQTerm

```cpp
/**
  Interpretation of CQTerm depends on which parameters are used.
  All unused parameters must be set to NULL_VALUE (int), nullptr (pointers),
  SF_NONE (SimpleFunction), common::NULL_VALUE_64 (Tint64_t).

  When these parameters are set:            then the meaning is:
        attr_id                     attribute value of the current
 table/TempTable attr_id, tab_id             attribute value of a given
 table/TempTable func, attr_id               attribute value of the current
 table/TempTable with a simple function applied func, attr_id, tab_id attribute
 value of a given table/TempTable with a simple function applied tab_id value of
 a TempTable (execution of a subquery) param_id                    parameter
 value c_term                      complex expression, defined elsewhere (?)

  Note: if all above are not used, it is interpreted as a constant (even if
 null) val_n                       numerical (fixed precision) constant val_t
 numerical (fixed precision) constant
 * note that all values may be safely copied (pointers are managed outside the
 class)
 */
struct CQTerm {
  common::ColumnType type;  // type of constant
  vcolumn::VirtualColumn *vc;
  types::CondArray cond_value;
  std::shared_ptr<utils::Hash64> cond_numvalue;

  int vc_id;         // virt column number set at compilation, = -1 for legacy cases
                     // (not using virt column)
  bool is_vc_owner;  // indicator if vc should be it deleted in destructor
  Item *item;
};

```