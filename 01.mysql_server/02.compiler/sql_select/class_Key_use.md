#1.class Key_use

```cpp
/**
  Information about usage of an index to satisfy an equality condition.
*/
class Key_use {
public:
  // We need the default constructor for unit testing.
  Key_use()
    : table(NULL),
      val(NULL),
      used_tables(0),
      key(0),
      keypart(0),
      optimize(0),
      keypart_map(0),
      ref_table_rows(0),
      null_rejecting(false),
      cond_guard(NULL),
      sj_pred_no(UINT_MAX)
  {}

  Key_use(TABLE *table_arg, Item *val_arg, table_map used_tables_arg,
          uint key_arg, uint keypart_arg, uint optimize_arg,
          key_part_map keypart_map_arg, ha_rows ref_table_rows_arg,
          bool null_rejecting_arg, bool *cond_guard_arg,
          uint sj_pred_no_arg) :
  table(table_arg), val(val_arg), used_tables(used_tables_arg),
  key(key_arg), keypart(keypart_arg), optimize(optimize_arg),
  keypart_map(keypart_map_arg), ref_table_rows(ref_table_rows_arg),
  null_rejecting(null_rejecting_arg), cond_guard(cond_guard_arg),
  sj_pred_no(sj_pred_no_arg)
  {}
  TABLE *table;            ///< table owning the index
  Item	*val;              ///< other side of the equality, or value if no field
  table_map used_tables;   ///< tables used on other side of equality
  uint key;                ///< number of index
  uint keypart;            ///< used part of the index
  uint optimize;           ///< 0, or KEY_OPTIMIZE_*
  key_part_map keypart_map;       ///< like keypart, but as a bitmap
  ha_rows      ref_table_rows;    ///< Estimate of how many rows for a key value
  /**
    If true, the comparison this value was created from will not be
    satisfied if val has NULL 'value'.
    Not used if the index is fulltext (such index cannot be used for
    equalities).
  */
  bool null_rejecting;
  /**
    !NULL - This Key_use was created from an equality that was wrapped into
            an Item_func_trig_cond. This means the equality (and validity of
            this Key_use element) can be turned on and off. The on/off state
            is indicted by the pointed value:
              *cond_guard == TRUE <=> equality condition is on
              *cond_guard == FALSE <=> equality condition is off

    NULL  - Otherwise (the source equality can't be turned off)

    Not used if the index is fulltext (such index cannot be used for
    equalities).
  */
  bool *cond_guard;
  /**
     0..63    <=> This was created from semi-join IN-equality # sj_pred_no.
     UINT_MAX  Otherwise

     Not used if the index is fulltext (such index cannot be used for
     semijoin).
  */
  uint         sj_pred_no;
};

```