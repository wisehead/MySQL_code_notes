#1.class QUICK_INDEX_MERGE_SELECT

```cpp
/*
  QUICK_INDEX_MERGE_SELECT - index_merge access method quick select.

    QUICK_INDEX_MERGE_SELECT uses
     * QUICK_RANGE_SELECTs to get rows
     * Unique class to remove duplicate rows

  INDEX MERGE OPTIMIZER
    Current implementation doesn't detect all cases where index_merge could
    be used, in particular:
     * index_merge will never be used if range scan is possible (even if
       range scan is more expensive)

     * index_merge+'using index' is not supported (this the consequence of
       the above restriction)

     * If WHERE part contains complex nested AND and OR conditions, some ways
       to retrieve rows using index_merge will not be considered. The choice
       of read plan may depend on the order of conjuncts/disjuncts in WHERE
       part of the query, see comments near imerge_list_or_list and
       SEL_IMERGE::or_sel_tree_with_checks functions for details.

     * There is no "index_merge_ref" method (but index_merge on non-first
       table in join is possible with 'range checked for each record').

    See comments around SEL_IMERGE class and test_quick_select for more
    details.

  ROW RETRIEVAL ALGORITHM

    index_merge uses Unique class for duplicates removal.  index_merge takes
    advantage of Clustered Primary Key (CPK) if the table has one.
    The index_merge algorithm consists of two phases:

    Phase 1 (implemented in QUICK_INDEX_MERGE_SELECT::prepare_unique):
    prepare()
    {
      activate 'index only';
      while(retrieve next row for non-CPK scan)
      {
        if (there is a CPK scan and row will be retrieved by it)
          skip this row;
        else
          put its rowid into Unique;
      }
      deactivate 'index only';
    }

    Phase 2 (implemented as sequence of QUICK_INDEX_MERGE_SELECT::get_next
    calls):

    fetch()
    {
      retrieve all rows from row pointers stored in Unique;
      free Unique;
      retrieve all rows for CPK scan;
    }
*/


class QUICK_INDEX_MERGE_SELECT : public QUICK_SELECT_I
{
  Unique *unique;
public:
  QUICK_INDEX_MERGE_SELECT(THD *thd, TABLE *table);
  ~QUICK_INDEX_MERGE_SELECT();

  int  init();
  void need_sorted_output() { DBUG_ASSERT(false); /* Can't do it */ }
  int  reset(void);
  int  get_next();
  bool reverse_sorted() const { return false; }
  bool reverse_sort_possible() const { return false; }
  bool unique_key_range() { return false; }
  int get_type() { return QS_TYPE_INDEX_MERGE; }
  void add_keys_and_lengths(String *key_names, String *used_lengths);
  void add_info_string(String *str);
  bool is_keys_used(const MY_BITMAP *fields);
#ifndef DBUG_OFF
  void dbug_dump(int indent, bool verbose);
#endif

  bool push_quick_back(QUICK_RANGE_SELECT *quick_sel_range);

  /* range quick selects this index_merge read consists of */
  List<QUICK_RANGE_SELECT> quick_selects;

  /* quick select that uses clustered primary key (NULL if none) */
  QUICK_RANGE_SELECT* pk_quick_select;

  /* true if this select is currently doing a clustered PK scan */
  bool  doing_pk_scan;

  MEM_ROOT alloc;
  THD *thd;
  int read_keys_and_merge();

  bool clustered_pk_range() { return MY_TEST(pk_quick_select); }

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

  /* used to get rows collected in Unique */
  READ_RECORD read_record;
};
```