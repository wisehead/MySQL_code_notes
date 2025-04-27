#1.class Item_func

```cpp
class Item_func :public Item_result_field
{
  typedef Item_result_field super;
protected:
  Item **args, *tmp_arg[2];
  /// Value used in calculation of result of const_item()
  bool const_item_cache;
  /*
    Allowed numbers of columns in result (usually 1, which means scalar value)
    0 means get this number from first argument
  */
  uint allowed_arg_cols;
  /// Value used in calculation of result of used_tables()
  table_map used_tables_cache;
  /// Value used in calculation of result of not_null_tables()
  table_map not_null_tables_cache;
public:
  uint arg_count;
  //bool const_item_cache;
  // When updating Functype with new spatial functions,
  // is_spatial_operator() should also be updated.
  enum Functype { UNKNOWN_FUNC,EQ_FUNC,EQUAL_FUNC,NE_FUNC,LT_FUNC,LE_FUNC,
		  GE_FUNC,GT_FUNC,FT_FUNC,
		  LIKE_FUNC,ISNULL_FUNC,ISNOTNULL_FUNC,
		  COND_AND_FUNC, COND_OR_FUNC, XOR_FUNC,
                  BETWEEN, IN_FUNC, MULT_EQUAL_FUNC,
		  INTERVAL_FUNC, ISNOTNULLTEST_FUNC,
		  SP_EQUALS_FUNC, SP_DISJOINT_FUNC,SP_INTERSECTS_FUNC,
		  SP_TOUCHES_FUNC,SP_CROSSES_FUNC,SP_WITHIN_FUNC,
		  SP_CONTAINS_FUNC,SP_COVEREDBY_FUNC,SP_COVERS_FUNC,
                  SP_OVERLAPS_FUNC,
		  SP_STARTPOINT,SP_ENDPOINT,SP_EXTERIORRING,
		  SP_POINTN,SP_GEOMETRYN,SP_INTERIORRINGN,
                  NOT_FUNC, NOT_ALL_FUNC,
                  NOW_FUNC, TRIG_COND_FUNC,
                  SUSERVAR_FUNC, GUSERVAR_FUNC, COLLATE_FUNC,
                  EXTRACT_FUNC, TYPECAST_FUNC, FUNC_SP, UDF_FUNC,
                  NEG_FUNC, GSYSVAR_FUNC };
  enum optimize_type { OPTIMIZE_NONE,OPTIMIZE_KEY,OPTIMIZE_OP, OPTIMIZE_NULL,
                       OPTIMIZE_EQUAL };
  enum Type type() const { return FUNC_ITEM; }
  virtual enum Functype functype() const   { return UNKNOWN_FUNC; }
  Item_func(void):
    allowed_arg_cols(1), arg_count(0)
  {
    args= tmp_arg;
    with_sum_func= 0;
  }

  explicit Item_func(const POS &pos)
    : super(pos), allowed_arg_cols(1), arg_count(0)
  {
    args= tmp_arg;
  }

  Item_func(Item *a):
    allowed_arg_cols(1), arg_count(1)
  {
    args= tmp_arg;
    args[0]= a;
    with_sum_func= a->with_sum_func;
  }
  Item_func(const POS &pos, Item *a): super(pos),
    allowed_arg_cols(1), arg_count(1)
  {
    args= tmp_arg;
    args[0]= a;
  }

  Item_func(Item *a,Item *b):
    allowed_arg_cols(1), arg_count(2)
  {
    args= tmp_arg;
    args[0]= a; args[1]= b;
    with_sum_func= a->with_sum_func || b->with_sum_func;
  }
  Item_func(const POS &pos, Item *a,Item *b): super(pos),
    allowed_arg_cols(1), arg_count(2)
  {
    args= tmp_arg;
    args[0]= a; args[1]= b;
  }

  Item_func(Item *a,Item *b,Item *c):
    allowed_arg_cols(1), arg_count(3)
  {
    if ((args= (Item**) sql_alloc(sizeof(Item*)*3)))
    {
      args[0]= a; args[1]= b; args[2]= c;
      with_sum_func= a->with_sum_func || b->with_sum_func || c->with_sum_func;
    }
    else
      arg_count= 0; // OOM
  }

  Item_func(const POS &pos, Item *a,Item *b,Item *c): super(pos),
    allowed_arg_cols(1), arg_count(3)
  {
    if ((args= (Item**) sql_alloc(sizeof(Item*)*3)))
    {
      args[0]= a; args[1]= b; args[2]= c;
    }
    else
      arg_count= 0; // OOM
  }

  Item_func(Item *a,Item *b,Item *c,Item *d):
    allowed_arg_cols(1), arg_count(4)
  {
    if ((args= (Item**) sql_alloc(sizeof(Item*)*4)))
    {
      args[0]= a; args[1]= b; args[2]= c; args[3]= d;
      with_sum_func= a->with_sum_func || b->with_sum_func ||
	c->with_sum_func || d->with_sum_func;
    }
    else
      arg_count= 0; // OOM
  }
  Item_func(const POS &pos, Item *a,Item *b,Item *c,Item *d): super(pos),
    allowed_arg_cols(1), arg_count(4)
  {
    if ((args= (Item**) sql_alloc(sizeof(Item*)*4)))
    {
      args[0]= a; args[1]= b; args[2]= c; args[3]= d;
    }
    else
      arg_count= 0; // OOM
  }

  Item_func(Item *a,Item *b,Item *c,Item *d,Item* e):
    allowed_arg_cols(1), arg_count(5)
  {
    if ((args= (Item**) sql_alloc(sizeof(Item*)*5)))
    {
      args[0]= a; args[1]= b; args[2]= c; args[3]= d; args[4]= e;
      with_sum_func= a->with_sum_func || b->with_sum_func ||
	c->with_sum_func || d->with_sum_func || e->with_sum_func ;
    }
    else
      arg_count= 0; // OOM
  }
  Item_func(const POS &pos, Item *a, Item *b, Item *c, Item *d, Item* e)
    : super(pos), allowed_arg_cols(1), arg_count(5)
  {
    if ((args= (Item**) sql_alloc(sizeof(Item*)*5)))
    {
      args[0]= a; args[1]= b; args[2]= c; args[3]= d; args[4]= e;
    }
    else
      arg_count= 0; // OOM
  }
  Item_func(Item *a,Item *b,Item *c,Item *d,Item* e,Item* f):
    allowed_arg_cols(1), arg_count(6)
  {
    if ((args= (Item**) sql_alloc(sizeof(Item*)*6)))
    {
      args[0]= a; args[1]= b; args[2]= c; args[3]= d; args[4]= e; args[5]= f;
      with_sum_func= a->with_sum_func || b->with_sum_func ||
      c->with_sum_func || d->with_sum_func || e->with_sum_func || f->with_sum_func;
    }
    else
      arg_count= 0; // OOM
  }
  Item_func(const POS &pos, Item *a, Item *b, Item *c, Item *d, Item* e, Item* f)
    : super(pos), allowed_arg_cols(1), arg_count(6)
  {
    if ((args= (Item**) sql_alloc(sizeof(Item*)*6)))
    {
      args[0]= a; args[1]= b; args[2]= c; args[3]= d; args[4]= e;args[5]= f;
    }
    else
      arg_count= 0; // OOM
  }
  Item_func(List<Item> &list);
  Item_func(const POS &pos, PT_item_list *opt_list);

  // Constructor used for Item_cond_and/or (see Item comment)
  Item_func(THD *thd, Item_func *item);

  virtual bool itemize(Parse_context *pc, Item **res);

  bool fix_fields(THD *, Item **ref);
  bool fix_func_arg(THD *, Item **arg);
  virtual void fix_after_pullout(st_select_lex *parent_select,
                                 st_select_lex *removed_select);
  table_map used_tables() const;
  /**
     Returns the pseudo tables depended upon in order to evaluate this
     function expression. The default implementation returns the empty
     set.
  */
  virtual table_map get_initial_pseudo_tables() const { return 0; }
  table_map not_null_tables() const;
  void update_used_tables();
  void set_used_tables(table_map map) { used_tables_cache= map; }
  void set_not_null_tables(table_map map) { not_null_tables_cache= map; }
  bool eq(const Item *item, bool binary_cmp) const;
  virtual optimize_type select_optimize() const { return OPTIMIZE_NONE; }
  virtual bool have_rev_func() const { return 0; }
  virtual Item *key_item() const { return args[0]; }
  virtual bool const_item() const { return const_item_cache; }
  inline Item **arguments() const
  { assert(argument_count() > 0); return args; }
  /**
    Copy arguments from list to args array

    @param list           function argument list
    @param context_free   true: for use in context-independent
                          constructors (Item_func(POS,...)) i.e. for use
                          in the parser
  */
  void set_arguments(List<Item> &list, bool context_free);
  inline uint argument_count() const { return arg_count; }
  inline void remove_arguments() { arg_count=0; }
  void split_sum_func(THD *thd, Ref_ptr_array ref_pointer_array,
                      List<Item> &fields);
  virtual void print(String *str, enum_query_type query_type);
  void print_op(String *str, enum_query_type query_type);
  void print_args(String *str, uint from, enum_query_type query_type);
  virtual void fix_num_length_and_dec();
  void count_only_length(Item **item, uint nitems);
  void count_real_length(Item **item, uint nitems);
  void count_decimal_length(Item **item, uint nitems);
  void count_datetime_length(Item **item, uint nitems);
  bool count_string_result_length(enum_field_types field_type,
                                  Item **item, uint nitems);
  bool get_arg0_date(MYSQL_TIME *ltime, my_time_flags_t fuzzy_date)
  {
    return (null_value=args[0]->get_date(ltime, fuzzy_date));
  }
  inline bool get_arg0_time(MYSQL_TIME *ltime)
  {
    return (null_value= args[0]->get_time(ltime));
  }
  bool is_null() { 
    update_null_value();
    return null_value; 
  }
  void signal_divide_by_null();
  void signal_invalid_argument_for_log();
  friend class udf_handler;
  Field *tmp_table_field() { return result_field; }
  Field *tmp_table_field(TABLE *t_arg);
  Item *get_tmp_table_item(THD *thd);

  my_decimal *val_decimal(my_decimal *);

  /**
    Same as save_in_field except that special logic is added
    to handle JSON values. If the target field has JSON type,
    then do NOT first serialize the JSON value into a string form.

    A better solution might be to put this logic into
    Item_func::save_in_field_inner() or even Item::save_in_field_inner().
    But that would mean providing val_json() overrides for
    more Item subclasses. And that feels like pulling on a
    ball of yarn late in the release cycle for 5.7. FIXME.

    @param[out] field  The field to set the value to.
    @retval 0         On success.
    @retval > 0       On error.
  */
  virtual type_conversion_status save_possibly_as_json(Field *field,
                                                       bool no_conversions);

  bool agg_arg_charsets(DTCollation &c, Item **items, uint nitems,
                        uint flags, int item_sep)
  {
    return agg_item_charsets(c, func_name(), items, nitems, flags, item_sep);
  }
  /*
    Aggregate arguments for string result, e.g: CONCAT(a,b)
    - convert to @@character_set_connection if all arguments are numbers
    - allow DERIVATION_NONE
  */
  bool agg_arg_charsets_for_string_result(DTCollation &c,
                                          Item **items, uint nitems,
                                          int item_sep= 1)
  {
    return agg_item_charsets_for_string_result(c, func_name(),
                                               items, nitems, item_sep);
  }
  /*
    Aggregate arguments for comparison, e.g: a=b, a LIKE b, a RLIKE b
    - don't convert to @@character_set_connection if all arguments are numbers
    - don't allow DERIVATION_NONE
  */
  bool agg_arg_charsets_for_comparison(DTCollation &c,
                                       Item **items, uint nitems,
                                       int item_sep= 1)
  {
    return agg_item_charsets_for_comparison(c, func_name(),
                                            items, nitems, item_sep);
  }
  /*
    Aggregate arguments for string result, when some comparison
    is involved internally, e.g: REPLACE(a,b,c)
    - convert to @@character_set_connection if all arguments are numbers
    - disallow DERIVATION_NONE
  */
  bool agg_arg_charsets_for_string_result_with_comparison(DTCollation &c,
                                                          Item **items,
                                                          uint nitems,
                                                          int item_sep= 1)
  {
    return agg_item_charsets_for_string_result_with_comparison(c, func_name(),
                                                               items, nitems,
                                                               item_sep);
  }
  bool walk(Item_processor processor, enum_walk walk, uchar *arg);
  Item *transform(Item_transformer transformer, uchar *arg);
  Item* compile(Item_analyzer analyzer, uchar **arg_p,
                Item_transformer transformer, uchar *arg_t);
  void traverse_cond(Cond_traverser traverser,
                     void * arg, traverse_order order);
  inline double fix_result(double value)
  {
    if (my_isfinite(value))
      return value;
    null_value=1;
    return 0.0;
  }
  inline void raise_numeric_overflow(const char *type_name)
  {
    char buf[256];
    String str(buf, sizeof(buf), system_charset_info);
    str.length(0);
    print(&str, QT_NO_DATA_EXPANSION);
    my_error(ER_DATA_OUT_OF_RANGE, MYF(0), type_name, str.c_ptr_safe());
  }
  inline double raise_float_overflow()
  {
    raise_numeric_overflow("DOUBLE");
    return 0.0;
  }
  inline longlong raise_integer_overflow()
  {
    raise_numeric_overflow(unsigned_flag ? "BIGINT UNSIGNED": "BIGINT");
    return 0;
  }
  inline int raise_decimal_overflow()
  {
    raise_numeric_overflow("DECIMAL");
    return E_DEC_OVERFLOW;
  }
  /**
     Throw an error if the input double number is not finite, i.e. is either
     +/-INF or NAN.
  */
  inline double check_float_overflow(double value)
  {
    return my_isfinite(value) ? value : raise_float_overflow();
  }
  /**
    Throw an error if the input BIGINT value represented by the
    (longlong value, bool unsigned flag) pair cannot be returned by the
    function, i.e. is not compatible with this Item's unsigned_flag.
  */
  inline longlong check_integer_overflow(longlong value, bool val_unsigned)
  {
    if ((unsigned_flag && !val_unsigned && value < 0) ||
        (!unsigned_flag && val_unsigned &&
         (ulonglong) value > (ulonglong) LLONG_MAX))
      return raise_integer_overflow();
    return value;
  }
  /**
     Throw an error if the error code of a DECIMAL operation is E_DEC_OVERFLOW.
  */
  inline int check_decimal_overflow(int error)
  {
    return (error == E_DEC_OVERFLOW) ? raise_decimal_overflow() : error;
  }

  bool has_timestamp_args()
  {
    assert(fixed == TRUE);
    for (uint i= 0; i < arg_count; i++)
    {
      if (args[i]->type() == Item::FIELD_ITEM &&
          args[i]->field_type() == MYSQL_TYPE_TIMESTAMP)
        return TRUE;
    }
    return FALSE;
  }

  bool has_date_args()
  {
    assert(fixed == TRUE);
    for (uint i= 0; i < arg_count; i++)
    {
      if (args[i]->type() == Item::FIELD_ITEM &&
          (args[i]->field_type() == MYSQL_TYPE_DATE ||
           args[i]->field_type() == MYSQL_TYPE_DATETIME))
        return TRUE;
    }
    return FALSE;
  }

  bool has_time_args()
  {
    assert(fixed == TRUE);
    for (uint i= 0; i < arg_count; i++)
    {
      if (args[i]->type() == Item::FIELD_ITEM &&
          (args[i]->field_type() == MYSQL_TYPE_TIME ||
           args[i]->field_type() == MYSQL_TYPE_DATETIME))
        return TRUE;
    }
    return FALSE;
  }

  bool has_datetime_args()
  {
    assert(fixed == TRUE);
    for (uint i= 0; i < arg_count; i++)
    {
      if (args[i]->type() == Item::FIELD_ITEM &&
          args[i]->field_type() == MYSQL_TYPE_DATETIME)
        return TRUE;
    }
    return FALSE;
  }

  /*
    We assume the result of any function that has a TIMESTAMP argument to be
    timezone-dependent, since a TIMESTAMP value in both numeric and string
    contexts is interpreted according to the current timezone.
    The only exception is UNIX_TIMESTAMP() which returns the internal
    representation of a TIMESTAMP argument verbatim, and thus does not depend on
    the timezone.
   */
  virtual bool check_valid_arguments_processor(uchar *bool_arg)
  {
    return has_timestamp_args();
  }

  virtual bool find_function_processor (uchar *arg)
  {
    return functype() == *(Functype *) arg;
  }
  virtual Item *gc_subst_transformer(uchar *arg);

  /**
    Does essentially the same as THD::change_item_tree, plus
    maintains any necessary any invariants.
  */
  virtual void replace_argument(THD *thd, Item **oldpp, Item *newp);

protected:
  /**
    Whether or not an item should contribute to the filtering effect
    (@see get_filtering_effect()). First it verifies that table
    requirements are satisfied as follows:

     1) The item must refer to a field in 'filter_for_table' in some
        way. This reference may be indirect through any number of
        intermediate items. For example, this item may be an
        Item_cond_and which refers to an Item_func_eq which refers to
        the field.
     2) The item must not refer to other tables than those already
        read and the table in 'filter_for_table'

    Then it contines to other properties as follows:

    Item_funcs represent "<operand1> OP <operand2> [OP ...]". If the
    Item_func is to contribute to the filtering effect, then

    1) one of the operands must be a field from 'filter_for_table' that is not
       in 'fields_to_ignore', and
    2) depending on the Item_func type filtering effect is calculated
       for, one or all [1] of the other operand(s) must be an available
       value, i.e.:
       - a constant, or
       - a constant subquery, or
       - a field value read from a table in 'read_tables', or
       - a second field in 'filter_for_table', or
       - a function that only refers to constants or tables in
         'read_tables', or
       - special case: an implicit value like NULL in the case of
         "field IS NULL". Such Item_funcs have arg_count==1.

    [1] "At least one" for multiple equality (X = Y = Z = ...), "all"
    for the rest (e.g. BETWEEN)

    @param read_tables       Tables earlier in the join sequence.
                             Predicates for table 'filter_for_table' that
                             rely on values from these tables can be part of
                             the filter effect.
    @param filter_for_table  The table we are calculating filter effect for

    @return Item_field that participates in the predicate if none of the
            requirements are broken, NULL otherwise

    @note: This function only applies to items doing comparison, i.e.
    boolean predicates. Unfortunately, some of those items do not
    inherit from Item_bool_func so the member function has to be
    placed in Item_func.
  */
  const Item_field*
    contributes_to_filter(table_map read_tables,
                          table_map filter_for_table,
                          const MY_BITMAP *fields_to_ignore) const;
  /**
    Named parameters are allowed in a parameter list

    The syntax to name parameters in a function call is as follow:
    <code>foo(expr AS named, expr named, expr AS "named", expr "named")</code>
    where "AS" is optional.
    Only UDF function support that syntax.

    @return true if the function item can have named parameters
  */
  virtual bool may_have_named_parameters() const { return false; }
};

```