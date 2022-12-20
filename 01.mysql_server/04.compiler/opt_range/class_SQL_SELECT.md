#1.class SQL_SELECT

```cpp

class SQL_SELECT :public Sql_alloc {
 public:
  QUICK_SELECT_I *quick;	// If quick-select used
  Item		*cond;		// where condition
  Item		*icp_cond;	// conditions pushed to index
  TABLE	*head;
  IO_CACHE file;		// Positions to used records
  ha_rows records;		// Records in use if read from file
  double read_time;		// Time to read rows
  key_map quick_keys;		// Possible quick keys
  key_map needed_reg;		// Possible quick keys after prev tables.
  table_map const_tables,read_tables;
  bool	free_cond;

  /**
    Used for QS_DYNAMIC_RANGE, i.e., "Range checked for each record".
    Used by optimizer tracing to decide whether or not dynamic range
    analysis of this select has been traced already. If optimizer
    trace option DYNAMIC_RANGE is enabled, range analysis will be
    traced with different ranges for every record to the left of this
    table in the join. If disabled, range analysis will only be traced
    for the first range.
  */
  bool traced_before;

  SQL_SELECT();
  ~SQL_SELECT();
  void cleanup();
  void set_quick(QUICK_SELECT_I *new_quick) { delete quick; quick= new_quick; }
  bool check_quick(THD *thd, bool force_quick_range, ha_rows limit)
  {
    key_map tmp(key_map::ALL_BITS);
    return test_quick_select(thd, tmp, 0, limit, force_quick_range,
                             ORDER::ORDER_NOT_RELEVANT) < 0;
  }
  inline bool skip_record(THD *thd, bool *skip_record)
  {
    *skip_record= cond ? cond->val_int() == FALSE : FALSE;
    return thd->is_error();
  }
  int test_quick_select(THD *thd, key_map keys, table_map prev_tables,
                        ha_rows limit, bool force_quick_range,
                        const ORDER::enum_order interesting_order);
};


```