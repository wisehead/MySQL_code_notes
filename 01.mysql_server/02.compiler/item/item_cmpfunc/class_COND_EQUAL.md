#1.class COND_EQUAL

```cpp

class COND_EQUAL: public Sql_alloc
{
public:
  uint max_members;               /* max number of members the current level
                                     list and all lower level lists */ 
  COND_EQUAL *upper_levels;       /* multiple equalities of upper and levels */
  List<Item_equal> current_level; /* list of multiple equalities of 
                                     the current and level           */
  COND_EQUAL()
  { 
    upper_levels= 0;
  }
};
```