#1.struct Item_cond_and

```cpp

class Item_cond_and :public Item_cond
{
public:
  COND_EQUAL cond_equal;  /* contains list of Item_equal objects for 
                             the current and level and reference
                             to multiple equalities of upper and levels */  
  Item_cond_and() :Item_cond() {}

  Item_cond_and(Item *i1,Item *i2) :Item_cond(i1,i2) {}
  Item_cond_and(const POS &pos, Item *i1, Item *i2) :Item_cond(pos, i1, i2) {}

  Item_cond_and(THD *thd, Item_cond_and *item) :Item_cond(thd, item) {}
  Item_cond_and(List<Item> &list_arg): Item_cond(list_arg) {}
  enum Functype functype() const { return COND_AND_FUNC; }
  longlong val_int();
  const char *func_name() const { return "and"; }
  Item* copy_andor_structure(THD *thd)
  {
    Item_cond_and *item;
    if ((item= new Item_cond_and(thd, this)))
      item->copy_andor_arguments(thd, this);
    return item;
  }
  Item *neg_transformer(THD *thd);
  bool gc_subst_analyzer(uchar **arg) { return true; }

  float get_filtering_effect(table_map filter_for_table,
                             table_map read_tables,
                             const MY_BITMAP *fields_to_ignore,
                             double rows_in_table);
};
```