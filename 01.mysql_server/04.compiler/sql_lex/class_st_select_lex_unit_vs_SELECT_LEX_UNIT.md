#1.class st_select_lex_unit

```cpp
class st_select_lex_unit: public st_select_lex_node {
protected:
  TABLE_LIST result_table_list;
  select_union *union_result;
  TABLE *table; /* temporary table using for appending UNION results */

  select_result *result;
  ulonglong found_rows_for_union;
  bool saved_error;

public:
  // Ensures that at least all members used during cleanup() are initialized.
  st_select_lex_unit()
    : union_result(NULL), table(NULL), result(NULL),
      cleaned(false),
      fake_select_lex(NULL),
      explain_marker(0)
  {
  }

  bool  prepared, // prepare phase already performed for UNION (unit)
    optimized, // optimize phase already performed for UNION (unit)
    executed, // already executed
    cleaned;

  // list of fields which points to temporary table for union
  List<Item> item_list;
  /*
    list of types of items inside union (used for union & derived tables)
    
    Item_type_holders from which this list consist may have pointers to Field,
    pointers is valid only after preparing SELECTS of this unit and before
    any SELECT of this unit execution

    TODO:
    Possibly this member should be protected, and its direct use replaced
    by get_unit_column_types(). Check the places where it is used.
  */
  List<Item> types;
  /*
    Pointer to 'last' select or pointer to unit where stored
    global parameters for union
  */
  st_select_lex *global_parameters;
  /* LIMIT clause runtime counters */
  ha_rows select_limit_cnt, offset_limit_cnt;
  /* not NULL if unit used in subselect, point to subselect item */
  Item_subselect *item;
  /* thread handler */
  THD *thd;
  /*
    SELECT_LEX for hidden SELECT in onion which process global
    ORDER BY and LIMIT
  */
  st_select_lex *fake_select_lex;

  st_select_lex *union_distinct; /* pointer to the last UNION DISTINCT */
  bool describe; /* union exec() called for EXPLAIN */

  /**
    Marker for subqueries in WHERE, HAVING, ORDER BY, GROUP BY and
    SELECT item lists

   See Item_subselect::explain_subquery_checker

   @note Actually, the type of this variable is Explain_context_enum, but .h
         files are too interlinked to include "opt_format.h" there
  */
  int explain_marker;

  void init_query();
  st_select_lex_unit* master_unit();
  st_select_lex* outer_select();
  st_select_lex* first_select()
  {
    return reinterpret_cast<st_select_lex*>(slave);
  }
  st_select_lex_unit* next_unit()
  {
    return reinterpret_cast<st_select_lex_unit*>(next);
  }
  void exclude_level();
  void exclude_tree();
  inline select_result *get_result() { return result; }

  /* UNION methods */
  bool prepare(THD *thd, select_result *result, ulong additional_options);
  bool optimize();
  // TODO: this should be moved out!!!!
  int optimize_for_stonedb();
  int optimize_after_stonedb();
  bool exec();
  bool explain();
  bool cleanup();
  bool cleanup_level();
  inline void unclean() { cleaned= 0; }
  void reinit_exec_mechanism();

  void print(String *str, enum_query_type query_type);

  bool add_fake_select_lex(THD *thd);
  bool init_prepare_fake_select_lex(THD *thd, bool no_const_tables);
  inline bool is_prepared() { return prepared; }
  bool change_result(select_result_interceptor *result,
                     select_result_interceptor *old_result);
  void set_limit(st_select_lex *values);
  void set_thd(THD *thd_arg) { thd= thd_arg; }
  inline bool is_union (); 

  friend void lex_start(THD *thd);
  friend bool subselect_union_engine::exec();

  List<Item> *get_unit_column_types();
  List<Item> *get_field_list();
private:
  void invalidate();
};
```