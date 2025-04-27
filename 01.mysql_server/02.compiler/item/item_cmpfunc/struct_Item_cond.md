 #1.struct Item_cond
 
 ```cpp
 class Item_cond :public Item_bool_func
{
  typedef Item_bool_func super;

protected:
  List<Item> list;
  bool abort_on_null;

public:
  /* Item_cond() is only used to create top level items */
  Item_cond(): Item_bool_func(), abort_on_null(1)
  { const_item_cache=0; }

  Item_cond(Item *i1,Item *i2)
    :Item_bool_func(), abort_on_null(0)
  {
    list.push_back(i1);
    list.push_back(i2);
  }
  Item_cond(const POS &pos, Item *i1, Item *i2)
    :Item_bool_func(pos), abort_on_null(0)
  {
    list.push_back(i1);
    list.push_back(i2);
  }

  Item_cond(THD *thd, Item_cond *item);
  Item_cond(List<Item> &nlist)
    :Item_bool_func(), list(nlist), abort_on_null(0) {}
  bool add(Item *item)
  {
    assert(item);
    return list.push_back(item);
  }
  bool add_at_head(Item *item)
  {
    assert(item);
    return list.push_front(item);
  }
  void add_at_head(List<Item> *nlist)
  {
    assert(nlist->elements);
    list.prepand(nlist);
  }

  virtual bool itemize(Parse_context *pc, Item **res);

  bool fix_fields(THD *, Item **ref);
  void fix_after_pullout(st_select_lex *parent_select,
                         st_select_lex *removed_select);

  enum Type type() const { return COND_ITEM; }
  List<Item>* argument_list() { return &list; }
  bool eq(const Item *item, bool binary_cmp) const;
  table_map used_tables() const { return used_tables_cache; }
  void update_used_tables();
  virtual void print(String *str, enum_query_type query_type);
  void split_sum_func(THD *thd, Ref_ptr_array ref_pointer_array,
                      List<Item> &fields);
  void top_level_item() { abort_on_null=1; }
  void copy_andor_arguments(THD *thd, Item_cond *item);
  bool walk(Item_processor processor, enum_walk walk, uchar *arg);
  Item *transform(Item_transformer transformer, uchar *arg);
  void traverse_cond(Cond_traverser, void *arg, traverse_order order);
  void neg_arguments(THD *thd);
  enum_field_types field_type() const { return MYSQL_TYPE_LONGLONG; }
  bool subst_argument_checker(uchar **arg) { return TRUE; }
  Item *compile(Item_analyzer analyzer, uchar **arg_p,
                Item_transformer transformer, uchar *arg_t);

  virtual bool equality_substitution_analyzer(uchar **arg) { return true; }
};

 ```