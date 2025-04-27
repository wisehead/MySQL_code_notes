#1.struct Item_int_func

```cpp
class Item_int_func :public Item_func
{
public:
  Item_int_func() :Item_func()
  { collation.set_numeric(); fix_char_length(21); }
  explicit Item_int_func(const POS &pos) :Item_func(pos)
  { collation.set_numeric(); fix_char_length(21); }

  Item_int_func(Item *a) :Item_func(a)
  { collation.set_numeric(); fix_char_length(21); }
  Item_int_func(const POS &pos, Item *a) :Item_func(pos, a)
  { collation.set_numeric(); fix_char_length(21); }

  Item_int_func(Item *a,Item *b) :Item_func(a,b)
  { collation.set_numeric(); fix_char_length(21); }
  Item_int_func(const POS &pos, Item *a,Item *b) :Item_func(pos, a,b)
  { collation.set_numeric(); fix_char_length(21); }

  Item_int_func(Item *a,Item *b,Item *c) :Item_func(a,b,c)
  { collation.set_numeric(); fix_char_length(21); }
  Item_int_func(const POS &pos, Item *a,Item *b,Item *c) :Item_func(pos, a,b,c)
  { collation.set_numeric(); fix_char_length(21); }

  Item_int_func(Item *a, Item *b, Item *c, Item *d): Item_func(a,b,c,d)
  { collation.set_numeric(); fix_char_length(21); }
  Item_int_func(const POS &pos, Item *a, Item *b, Item *c, Item *d)
    :Item_func(pos,a,b,c,d)
  { collation.set_numeric(); fix_char_length(21); }

  Item_int_func(List<Item> &list) :Item_func(list)
  { collation.set_numeric(); fix_char_length(21); }
  Item_int_func(const POS &pos, PT_item_list *opt_list)
    :Item_func(pos, opt_list)
  { collation.set_numeric(); fix_char_length(21); }

  Item_int_func(THD *thd, Item_int_func *item) :Item_func(thd, item)
  { collation.set_numeric(); }
  double val_real();
  String *val_str(String*str);
  bool get_date(MYSQL_TIME *ltime, my_time_flags_t fuzzydate)
  {
    return get_date_from_int(ltime, fuzzydate);
  }
  bool get_time(MYSQL_TIME *ltime)
  {
    return get_time_from_int(ltime);
  }
  enum Item_result result_type () const { return INT_RESULT; }
  void fix_length_and_dec() {}
};

```