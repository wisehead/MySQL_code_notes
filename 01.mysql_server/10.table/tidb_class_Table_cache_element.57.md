#1.class Table_cache_element

```cpp
/**
  Element that represents the table in the specific table cache.
  Plays for table cache instance role similar to role of TABLE_SHARE
  for table definition cache.

  It is an implementation detail of Table_cache and is present
  in the header file only to allow inlining of some methods.
*/

class Table_cache_element
{
private:
  /*
    Doubly-linked (back-linked) lists of used and unused TABLE objects
    for this table in this table cache (one such list per table cache).
  */
  typedef I_P_List <TABLE,
                    I_P_List_adapter<TABLE,
                                     &TABLE::cache_next,
                                     &TABLE::cache_prev> > TABLE_list;

  TABLE_list used_tables;
  TABLE_list free_tables;
  TABLE_SHARE *share;

public:

  Table_cache_element(TABLE_SHARE *share_arg)
    : share(share_arg)
  {
  }

  TABLE_SHARE * get_share() const { return share; };

  friend class Table_cache;
  friend class Table_cache_manager;
  friend class Table_cache_iterator;
};
```