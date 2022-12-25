#<center>Item</center>

#2. cmp_item_row

```cpp
//sql/item_cmpfunc.h
class cmp_item_row :public cmp_item
{
  cmp_item **comparators;
  uint n;
public:
  cmp_item_row(): comparators(0), n(0) {}
  ~cmp_item_row();
  void store_value(Item *item);
  inline void alloc_comparators();
  int cmp(Item *arg);
  int compare(cmp_item *arg);
  cmp_item *make_same();
  void store_value_by_template(cmp_item *tmpl, Item *);
  friend void Item_func_in::fix_length_and_dec();
};
```

#3.class cmp_item

```cpp
//sql/item_cmpfunc.h
/*
** Classes for easy comparing of non const items
*/

class cmp_item :public Sql_alloc
{
public:
  const CHARSET_INFO *cmp_charset;
  cmp_item() { cmp_charset= &my_charset_bin; }
  virtual ~cmp_item() {}
  virtual void store_value(Item *item)= 0;
  virtual int cmp(Item *item)= 0;
  // for optimized IN with row
  virtual int compare(cmp_item *item)= 0;
  static cmp_item* get_comparator(Item_result type, const CHARSET_INFO *cs);
  virtual cmp_item *make_same()= 0;
  virtual void store_value_by_template(cmp_item *tmpl, Item *item)
  {
    store_value(item);
  }
};
```

#4. cmp_item_sort_string

```cpp
class cmp_item_sort_string :public cmp_item_string
{
protected:
  char value_buff[STRING_BUFFER_USUAL_SIZE];
  String value;
public:
  cmp_item_sort_string():
    cmp_item_string() {}
  cmp_item_sort_string(const CHARSET_INFO *cs):
    cmp_item_string(cs),
    value(value_buff, sizeof(value_buff), cs) {}
  void store_value(Item *item)
  {
    String *res= item->val_str(&value);
    if(res && (res != &value))
    {
      // 'res' may point in item's temporary internal data, so make a copy
      value.copy(*res);
    }
    value_res= &value;
  }
  int cmp(Item *arg)
  {
    char buff[STRING_BUFFER_USUAL_SIZE];
    String tmp(buff, sizeof(buff), cmp_charset), *res;
    res= arg->val_str(&tmp);
    return (value_res ? (res ? sortcmp(value_res, res, cmp_charset) : 1) :
            (res ? -1 : 0));
  }
  int compare(cmp_item *ci)
  {
    cmp_item_string *l_cmp= (cmp_item_string *) ci;
    return sortcmp(value_res, l_cmp->value_res, cmp_charset);
  }
  cmp_item *make_same();
  void set_charset(const CHARSET_INFO *cs)
  {
    cmp_charset= cs;
    value.set_quick(value_buff, sizeof(value_buff), cs);
  }
};

```