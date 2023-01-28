#1. Item_field

```cpp
class Item_field :public Item_ident
{
protected:
  void set_field(Field *field);
public:
  Field *field,*result_field;
  Item_equal *item_equal;
  bool no_const_subst;
  /*
    if any_privileges set to TRUE then here real effective privileges will
    be stored
  */
  uint have_privileges;
  /* field need any privileges (for VIEW creation) */
  bool any_privileges;
  Item_field(Name_resolution_context *context_arg,
             const char *db_arg,const char *table_name_arg,
         const char *field_name_arg);
  /*
    Constructor needed to process subquery with temporary tables (see Item).
    Notice that it will have no name resolution context.
  */
  Item_field(THD *thd, Item_field *item);
  /*
    Ensures that field, table, and database names will live as long as
    Item_field (this is important in prepared statements).
  */
  Item_field(THD *thd, Name_resolution_context *context_arg, Field *field);
  /*
    If this constructor is used, fix_fields() won't work, because
    db_name, table_name and column_name are unknown. It's necessary to call
    reset_field() before fix_fields() for all fields created this way.
  */
  Item_field(Field *field);
  enum Type type() const { return FIELD_ITEM; }
  bool eq(const Item *item, bool binary_cmp) const;
  double val_real();
  longlong val_int();
  longlong val_time_temporal();
  longlong val_date_temporal();
  my_decimal *val_decimal(my_decimal *);
  String *val_str(String*);
  double val_result();
  longlong val_int_result();
  longlong val_time_temporal_result();
  longlong val_date_temporal_result();
  String *str_result(String* tmp);
  my_decimal *val_decimal_result(my_decimal *);
  bool val_bool_result();
  bool is_null_result();
  bool send(Protocol *protocol, String *str_arg);
  void reset_field(Field *f);
  bool fix_fields(THD *, Item **);
  void make_field(Send_field *tmp_field);
  type_conversion_status save_in_field(Field *field,bool no_conversions);
  void save_org_in_field(Field *field);
  table_map used_tables() const;
  virtual table_map resolved_used_tables() const;
  enum Item_result result_type () const
  {
    return field->result_type();
  }
  enum Item_result numeric_context_result_type() const
  {
    return field->numeric_context_result_type();
  }
  Item_result cast_to_int_type() const
  {
    return field->cast_to_int_type();
  }
  enum_field_types field_type() const
  {
    return field->type();
  }
  enum_monotonicity_info get_monotonicity_info() const
  {
    return MONOTONIC_STRICT_INCREASING;
  }
  longlong val_int_endpoint(bool left_endp, bool *incl_endp);
  Field *get_tmp_table_field() { return result_field; }
  Field *tmp_table_field(TABLE *t_arg) { return result_field; }
  bool get_date(MYSQL_TIME *ltime,uint fuzzydate);
  bool get_date_result(MYSQL_TIME *ltime,uint fuzzydate);
  bool get_time(MYSQL_TIME *ltime);
  bool get_timeval(struct timeval *tm, int *warnings);
  bool is_null() { return field->is_null(); }
  void update_null_value();
  Item *get_tmp_table_item(THD *thd);
  bool collect_item_field_processor(uchar * arg);
  bool add_field_to_set_processor(uchar * arg);
  bool remove_column_from_bitmap(uchar * arg);
  bool find_item_in_field_list_processor(uchar *arg);
  bool register_field_in_read_map(uchar *arg);
  bool check_partition_func_processor(uchar *int_arg) {return FALSE;}
  void cleanup();
  Item_equal *find_item_equal(COND_EQUAL *cond_equal);
  bool subst_argument_checker(uchar **arg);
  Item *equal_fields_propagator(uchar *arg);
  bool set_no_const_sub(uchar *arg);
  Item *replace_equal_field(uchar *arg);
  inline uint32 max_disp_length() { return field->max_display_length(); }
  Item_field *field_for_view_update() { return this; }
  Item *safe_charset_converter(const CHARSET_INFO *tocs);
  int fix_outer_field(THD *thd, Field **field, Item **reference);
  virtual Item *update_value_transformer(uchar *select_arg);
  virtual bool item_field_by_name_analyzer(uchar **arg);
  virtual Item* item_field_by_name_transformer(uchar *arg);
  virtual void print(String *str, enum_query_type query_type);
  bool is_outer_field() const
  {
    DBUG_ASSERT(fixed);
    return field->table->pos_in_table_list->outer_join ||
           field->table->pos_in_table_list->outer_join_nest();
  }
  Field::geometry_type get_geometry_type() const
  {
    DBUG_ASSERT(field_type() == MYSQL_TYPE_GEOMETRY);
    return field->get_geometry_type();
  }
  const CHARSET_INFO *charset_for_protocol(void) const
  { return field->charset_for_protocol(); }

#ifndef DBUG_OFF
  void dbug_print()
  {
    fprintf(DBUG_FILE, "<field ");
    if (field)
    {
      fprintf(DBUG_FILE, "'%s.%s': ", field->table->alias, field->field_name);
      field->dbug_print();
    }
    else
      fprintf(DBUG_FILE, "NULL");

    fprintf(DBUG_FILE, ", result_field: ");
    if (result_field)
    {
      fprintf(DBUG_FILE, "'%s.%s': ",
              result_field->table->alias, result_field->field_name);
      result_field->dbug_print();
    }
    else
      fprintf(DBUG_FILE, "NULL");
    fprintf(DBUG_FILE, ">\n");
  }
#endif

  /// Pushes the item to select_lex.non_agg_fields() and updates its marker.
  bool push_to_non_agg_fields(st_select_lex *select_lex);

  friend class Item_default_value;
  friend class Item_insert_value;
  friend class st_select_lex_unit;
};    
```