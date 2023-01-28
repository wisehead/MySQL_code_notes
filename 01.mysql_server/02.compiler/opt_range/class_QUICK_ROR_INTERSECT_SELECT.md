#1.class QUICK_ROR_INTERSECT_SELECT

```cpp
/*
  Rowid-Ordered Retrieval (ROR) index intersection quick select.
  This quick select produces intersection of row sequences returned
  by several QUICK_RANGE_SELECTs it "merges".

  All merged QUICK_RANGE_SELECTs must return rowids in rowid order.
  QUICK_ROR_INTERSECT_SELECT will return rows in rowid order, too.

  All merged quick selects retrieve {rowid, covered_fields} tuples (not full
  table records).
  QUICK_ROR_INTERSECT_SELECT retrieves full records if it is not being used
  by QUICK_ROR_INTERSECT_SELECT and all merged quick selects together don't
  cover needed all fields.

  If one of the merged quick selects is a Clustered PK range scan, it is
  used only to filter rowid sequence produced by other merged quick selects.
*/

class QUICK_ROR_INTERSECT_SELECT : public QUICK_SELECT_I
{
public:
  QUICK_ROR_INTERSECT_SELECT(THD *thd, TABLE *table,
                             bool retrieve_full_rows,
                             MEM_ROOT *parent_alloc);
  ~QUICK_ROR_INTERSECT_SELECT();

  int  init();
  void need_sorted_output() { DBUG_ASSERT(false); /* Can't do it */ }
  int  reset(void);
  int  get_next();
  bool reverse_sorted() const { return false; }
  bool reverse_sort_possible() const { return false; }
  bool unique_key_range() { return false; }
  int get_type() { return QS_TYPE_ROR_INTERSECT; }
  void add_keys_and_lengths(String *key_names, String *used_lengths);
  void add_info_string(String *str);
  bool is_keys_used(const MY_BITMAP *fields);
#ifndef DBUG_OFF
  void dbug_dump(int indent, bool verbose);
#endif
  int init_ror_merged_scan(bool reuse_handler);
  bool push_quick_back(QUICK_RANGE_SELECT *quick_sel_range);

  /*
    Range quick selects this intersection consists of, not including
    cpk_quick.
  */
  List<QUICK_RANGE_SELECT> quick_selects;

  virtual bool is_valid()
  {
    List_iterator_fast<QUICK_RANGE_SELECT> it(quick_selects);
    QUICK_RANGE_SELECT *quick;
    bool valid= true;
    while ((quick= it++))
    {
      if (!quick->is_valid())
      {
        valid= false;
        break;
      }
    }
    return valid;
  }

  /*
    Merged quick select that uses Clustered PK, if there is one. This quick
    select is not used for row retrieval, it is used for row retrieval.
  */
  QUICK_RANGE_SELECT *cpk_quick;

  MEM_ROOT alloc; /* Memory pool for this and merged quick selects data. */
  THD *thd;       /* current thread */
  bool need_to_fetch_row; /* if true, do retrieve full table records. */
  /* in top-level quick select, true if merged scans where initialized */
  bool scans_inited; 
};
```