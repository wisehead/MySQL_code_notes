#1.class QUICK_ROR_UNION_SELECT

```cpp
/*
  Rowid-Ordered Retrieval index union select.
  This quick select produces union of row sequences returned by several
  quick select it "merges".

  All merged quick selects must return rowids in rowid order.
  QUICK_ROR_UNION_SELECT will return rows in rowid order, too.

  All merged quick selects are set not to retrieve full table records.
  ROR-union quick select always retrieves full records.

*/

class QUICK_ROR_UNION_SELECT : public QUICK_SELECT_I
{
public:
  QUICK_ROR_UNION_SELECT(THD *thd, TABLE *table);
  ~QUICK_ROR_UNION_SELECT();

  int  init();
  void need_sorted_output() { DBUG_ASSERT(false); /* Can't do it */ }
  int  reset(void);
  int  get_next();
  bool reverse_sorted() const { return false; }
  bool reverse_sort_possible() const { return false; }
  bool unique_key_range() { return false; }
  int get_type() { return QS_TYPE_ROR_UNION; }
  void add_keys_and_lengths(String *key_names, String *used_lengths);
  void add_info_string(String *str);
  bool is_keys_used(const MY_BITMAP *fields);
#ifndef DBUG_OFF
  void dbug_dump(int indent, bool verbose);
#endif

  bool push_quick_back(QUICK_SELECT_I *quick_sel_range);

  List<QUICK_SELECT_I> quick_selects; /* Merged quick selects */

  virtual bool is_valid()
  {
    List_iterator_fast<QUICK_SELECT_I> it(quick_selects);
    QUICK_SELECT_I *quick;
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

  QUEUE queue;    /* Priority queue for merge operation */
  MEM_ROOT alloc; /* Memory pool for this and merged quick selects data. */

  THD *thd;             /* current thread */
  uchar *cur_rowid;      /* buffer used in get_next() */
  uchar *prev_rowid;     /* rowid of last row returned by get_next() */
  bool have_prev_rowid; /* true if prev_rowid has valid data */
  uint rowid_length;    /* table rowid length */
private:
  bool scans_inited; 
};
```