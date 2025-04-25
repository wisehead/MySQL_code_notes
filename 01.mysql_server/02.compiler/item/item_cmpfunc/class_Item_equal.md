#1.class Item_equal

```cpp
/*
  The class Item_equal is used to represent conjunctions of equality
  predicates of the form field1 = field2, and field=const in where
  conditions and on expressions.

  All equality predicates of the form field1=field2 contained in a
  conjunction are substituted for a sequence of items of this class.
  An item of this class Item_equal(f1,f2,...fk) represents a
  multiple equality f1=f2=...=fk.

  If a conjunction contains predicates f1=f2 and f2=f3, a new item of
  this class is created Item_equal(f1,f2,f3) representing the multiple
  equality f1=f2=f3 that substitutes the above equality predicates in
  the conjunction.
  A conjunction of the predicates f2=f1 and f3=f1 and f3=f2 will be
  substituted for the item representing the same multiple equality
  f1=f2=f3.
  An item Item_equal(f1,f2) can appear instead of a conjunction of 
  f2=f1 and f1=f2, or instead of just the predicate f1=f2.

  An item of the class Item_equal inherits equalities from outer 
  conjunctive levels.

  Suppose we have a where condition of the following form:
  WHERE f1=f2 AND f3=f4 AND f3=f5 AND ... AND (...OR (f1=f3 AND ...)).
  In this case:
    f1=f2 will be substituted for Item_equal(f1,f2);
    f3=f4 and f3=f5  will be substituted for Item_equal(f3,f4,f5);
    f1=f3 will be substituted for Item_equal(f1,f2,f3,f4,f5);

  An object of the class Item_equal can contain an optional constant
  item c. Then it represents a multiple equality of the form 
  c=f1=...=fk.

  Objects of the class Item_equal are used for the following:

  1. An object Item_equal(t1.f1,...,tk.fk) allows us to consider any
  pair of tables ti and tj as joined by an equi-condition.
  Thus it provide us with additional access paths from table to table.

  2. An object Item_equal(t1.f1,...,tk.fk) is applied to deduce new
  SARGable predicates:
    f1=...=fk AND P(fi) => f1=...=fk AND P(fi) AND P(fj).
  It also can give us additional index scans and can allow us to
  improve selectivity estimates.

  3. An object Item_equal(t1.f1,...,tk.fk) is used to optimize the 
  selected execution plan for the query: if table ti is accessed 
  before the table tj then in any predicate P in the where condition
  the occurrence of tj.fj is substituted for ti.fi. This can allow
  an evaluation of the predicate at an earlier step.

  When feature 1 is supported they say that join transitive closure 
  is employed.
  When feature 2 is supported they say that search argument transitive
  closure is employed.
  Both features are usually supported by preprocessing original query and
  adding additional predicates.
  We do not just add predicates, we rather dynamically replace some
  predicates that can not be used to access tables in the investigated
  plan for those, obtained by substitution of some fields for equal fields,
  that can be used.     

  Prepared Statements/Stored Procedures note: instances of class
  Item_equal are created only at the time a PS/SP is executed and
  are deleted in the end of execution. All changes made to these
  objects need not be registered in the list of changes of the parse
  tree and do not harm PS/SP re-execution.

  Item equal objects are employed only at the optimize phase. Usually they are
  not supposed to be evaluated.  Yet in some cases we call the method val_int()
  for them. We have to take care of restricting the predicate such an
  object represents f1=f2= ...=fn to the projection of known fields fi1=...=fik.
*/
struct st_join_table;

class Item_equal: public Item_bool_func
{
  List<Item_field> fields; /* list of equal field items                    */
  Item *const_item;        /* optional constant item equal to fields items */
  cmp_item *eval_item;
  Arg_comparator cmp;
  bool cond_false;
  bool compare_as_dates;
public:
  inline Item_equal()
    : Item_bool_func(), const_item(0), eval_item(0), cond_false(0)
  { const_item_cache=0 ;}
  Item_equal(Item_field *f1, Item_field *f2);
  Item_equal(Item *c, Item_field *f);
  Item_equal(Item_equal *item_equal);
  virtual ~Item_equal()
  {
    delete eval_item;
  }

  inline Item* get_const() { return const_item; }
  bool compare_const(THD *thd, Item *c);
  bool add(THD *thd, Item *c, Item_field *f);
  bool add(THD *thd, Item *c);
  void add(Item_field *f);
  uint members();
  bool contains(Field *field);
  /**
    Get the first field of multiple equality, use for semantic checking.

    @retval First field in the multiple equality.
  */
  Item_field* get_first() { return fields.head(); }
  Item_field* get_subst_item(const Item_field *field);
  bool merge(THD *thd, Item_equal *item);
  bool update_const(THD *thd);
  enum Functype functype() const { return MULT_EQUAL_FUNC; }
  longlong val_int(); 
  const char *func_name() const { return "multiple equal"; }
  optimize_type select_optimize() const { return OPTIMIZE_EQUAL; }
  void sort(Item_field_cmpfunc compare, void *arg);
  friend class Item_equal_iterator;
  void fix_length_and_dec();
  bool fix_fields(THD *thd, Item **ref);
  void update_used_tables();
  bool walk(Item_processor processor, enum_walk walk, uchar *arg);
  Item *transform(Item_transformer transformer, uchar *arg);
  virtual void print(String *str, enum_query_type query_type);
  const CHARSET_INFO *compare_collation() 
  { return fields.head()->collation.collation; }

  virtual bool equality_substitution_analyzer(uchar **arg) { return true; }

  virtual Item* equality_substitution_transformer(uchar *arg);

  float get_filtering_effect(table_map filter_for_table,
                             table_map read_tables,
                             const MY_BITMAP *fields_to_ignore,
                             double rows_in_table);
}; 

```