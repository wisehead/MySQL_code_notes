#1.class Item_Ident

```cpp
class Item_ident :public Item
{
protected:
  /*
    We have to store initial values of db_name, table_name and field_name
    to be able to restore them during cleanup() because they can be
    updated during fix_fields() to values from Field object and life-time
    of those is shorter than life-time of Item_field.
  */
  const char *orig_db_name;
  const char *orig_table_name;
  const char *orig_field_name;

public:
  Name_resolution_context *context;
  const char *db_name;
  const char *table_name;
  const char *field_name;
  bool alias_name_used; /* true if item was resolved against alias */
  /*
    Cached value of index for this field in table->field array, used by prep.
    stmts for speeding up their re-execution. Holds NO_CACHED_FIELD_INDEX
    if index value is not known.
  */
  uint cached_field_index;
  /*
    Cached pointer to table which contains this field, used for the same reason
    by prep. stmt. too in case then we have not-fully qualified field.
    0 - means no cached value.
  */
  TABLE_LIST *cached_table;
  st_select_lex *depended_from;
  Item_ident(Name_resolution_context *context_arg,
             const char *db_name_arg, const char *table_name_arg,
             const char *field_name_arg);
  Item_ident(THD *thd, Item_ident *item);
  const char *full_name() const;
  virtual void fix_after_pullout(st_select_lex *parent_select,
                                 st_select_lex *removed_select);
  void cleanup();
  bool remove_dependence_processor(uchar * arg);
  virtual void print(String *str, enum_query_type query_type);
  virtual bool change_context_processor(uchar *cntx)
    { context= (Name_resolution_context *)cntx; return FALSE; }
  friend bool insert_fields(THD *thd, Name_resolution_context *context,
                            const char *db_name,
                            const char *table_name, List_iterator<Item> *it,
                            bool any_privileges);
};

```