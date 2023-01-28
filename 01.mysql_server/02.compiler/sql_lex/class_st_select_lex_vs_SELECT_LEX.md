#1.class st_select_lex

```cpp
/*
  SELECT_LEX - store information of parsed SELECT statment
*/
class st_select_lex: public st_select_lex_node
{
public:
  Name_resolution_context context;
  /*
    Two fields used by semi-join transformations to know when semi-join is
    possible, and in which condition tree the subquery predicate is located.
  */
  enum Resolve_place { RESOLVE_NONE, RESOLVE_JOIN_NEST, RESOLVE_CONDITION,
                       RESOLVE_HAVING };
  Resolve_place resolve_place; // Indicates part of query being resolved
  TABLE_LIST *resolve_nest;    // Used when resolving outer join condition
  char *db;
  Item *where, *having;                         /* WHERE & HAVING clauses */
  Item *prep_where; /* saved WHERE clause for prepared statement processing */
  Item *prep_having;/* saved HAVING clause for prepared statement processing */
  /**
    Saved values of the WHERE and HAVING clauses. Allowed values are: 
     - COND_UNDEF if the condition was not specified in the query or if it 
       has not been optimized yet
     - COND_TRUE if the condition is always true
     - COND_FALSE if the condition is impossible
     - COND_OK otherwise
  */
  Item::cond_result cond_value, having_value;
  /* point on lex in which it was created, used in view subquery detection */
  LEX *parent_lex;
  enum olap_type olap;
  /* FROM clause - points to the beginning of the TABLE_LIST::next_local list. */
  SQL_I_List<TABLE_LIST>  table_list;

  /*
    GROUP BY clause.
    This list may be mutated during optimization (by remove_const()),
    so for prepared statements, we keep a copy of the ORDER.next pointers in
    group_list_ptrs, and re-establish the original list before each execution.
  */
  SQL_I_List<ORDER>       group_list;
  Group_list_ptrs        *group_list_ptrs;

  /**
    List of fields & expressions.

    SELECT: Fields and expressions in the SELECT list.
    UPDATE: Fields in the SET clause.
  */
  List<Item>          item_list;
  List<String>        interval_list;
  bool	              is_item_list_lookup;
  /* 
    Usualy it is pointer to ftfunc_list_alloc, but in union used to create fake
    select_lex for calling mysql_select under results of union
  */
  List<Item_func_match> *ftfunc_list;
  List<Item_func_match> ftfunc_list_alloc;
  JOIN *join; /* after JOIN::prepare it is pointer to corresponding JOIN */
  List<TABLE_LIST> top_join_list; /* join list of the top level          */
  List<TABLE_LIST> *join_list;    /* list for the currently parsed join  */
  TABLE_LIST *embedding;          /* table embedding to the above list   */
  /// List of semi-join nests generated for this query block
  List<TABLE_LIST> sj_nests;
  //Dynamic_array<TABLE_LIST*> sj_nests; psergey-5:
  /*
    Beginning of the list of leaves in a FROM clause, where the leaves
    inlcude all base tables including view tables. The tables are connected
    by TABLE_LIST::next_leaf, so leaf_tables points to the left-most leaf.
  */
  TABLE_LIST *leaf_tables;
  /**
    SELECT_LEX type enum
  */
  enum type_enum {
    SLT_NONE= 0,
    SLT_PRIMARY,
    SLT_SIMPLE,
    SLT_DERIVED,
    SLT_SUBQUERY,
    SLT_UNION,
    SLT_UNION_RESULT,
    SLT_MATERIALIZED,
  // Total:
    SLT_total ///< fake type, total number of all valid types
  // Don't insert new types below this line!
  };

  /*
    ORDER BY clause.
    This list may be mutated during optimization (by remove_const()),
    so for prepared statements, we keep a copy of the ORDER.next pointers in
    order_list_ptrs, and re-establish the original list before each execution.
  */
  SQL_I_List<ORDER> order_list;
  Group_list_ptrs *order_list_ptrs;

  SQL_I_List<ORDER> gorder_list;
  Item *select_limit, *offset_limit;  /* LIMIT clause parameters */

  /// Array of pointers to top elements of all_fields list
  Ref_ptr_array ref_pointer_array;

  /// Number of derived tables and views
  uint derived_table_count;
  /// Number of materialized derived tables and views
  uint materialized_table_count;
  /// Number of partitioned tables
  uint partitioned_table_count;
  /*
    number of items in select_list and HAVING clause used to get number
    bigger then can be number of entries that will be added to all item
    list during split_sum_func
  */
  uint select_n_having_items;
  uint cond_count;    /* number of arguments of and/or/xor in where/having/on */
  uint between_count; /* number of between predicates in where/having/on      */
  uint max_equal_elems; /* maximal number of elements in multiple equalities  */
  /*
    Number of fields used in select list or where clause of current select
    and all inner subselects.
  */
  uint select_n_where_fields;
  enum_parsing_place parsing_place; /* where we are parsing expression */
  bool with_sum_func;   /* sum function indicator */

  ulong table_join_options;
  uint in_sum_expr;
  uint select_number; /* number of select (used for EXPLAIN) */
  /**
    Nesting level of query block, outer-most query block has level 0,
    its subqueries have level 1, etc. @see also sql/item_sum.h.
  */
  int nest_level;
  /* Circularly linked list of sum func in nested selects */
  Item_sum *inner_sum_func_list;
  uint with_wild; /* item list contain '*' */
  bool  braces;   	/* SELECT ... UNION (SELECT ... ) <- this braces */
  /* TRUE when having fix field called in processing of this SELECT */
  bool having_fix_field;
  /* TRUE when GROUP BY fix field called in processing of this SELECT */
  bool group_fix_field;
  /* List of references to fields referenced from inner selects */
  List<Item_outer_ref> inner_refs_list;
  /* Number of Item_sum-derived objects in this SELECT */
  uint n_sum_items;
  /* Number of Item_sum-derived objects in children and descendant SELECTs */
  uint n_child_sum_items;

  /* explicit LIMIT clause was used */
  bool explicit_limit;
  /*
    there are subquery in HAVING clause => we can't close tables before
    query processing end even if we use temporary table
  */
  bool subquery_in_having;
  /*
    This variable is required to ensure proper work of subqueries and
    stored procedures. Generally, one should use the states of
    Query_arena to determine if it's a statement prepare or first
    execution of a stored procedure. However, in case when there was an
    error during the first execution of a stored procedure, the SP body
    is not expelled from the SP cache. Therefore, a deeply nested
    subquery might be left unoptimized. So we need this per-subquery
    variable to inidicate the optimization/execution state of every
    subquery. Prepared statements work OK in that regard, as in
    case of an error during prepare the PS is not created.
  */
  bool first_execution;
  bool first_natural_join_processing;
  bool first_cond_optimization;
  /* do not wrap view fields with Item_ref */
  bool no_wrap_view_item;
  /* exclude this select from check of unique_table() */
  bool exclude_from_table_unique_test;
  /* List of table columns which are not under an aggregate function */
  List<Item_field> non_agg_fields;

  /// @See cur_pos_in_all_fields below
  static const int ALL_FIELDS_UNDEF_POS= INT_MIN;

  /**
     Used only for ONLY_FULL_GROUP_BY.
     When we call fix_fields(), this member should be set as follows:
     - if the item should honour ONLY_FULL_GROUP_BY (i.e. is in the SELECT
     list or is a hidden ORDER BY item), cur_pos_in_all_fields is the position
     of the item in join->all_fields with this convention: position of the
     first item of the SELECT list is 0; item before this (in direction of the
     front) has position -1, whereas item after has position 1.
     - otherwise, cur_pos_in_all_fields is ALL_FIELDS_UNDEF_POS.
  */
  int cur_pos_in_all_fields;

  List<udf_func>     udf_list;                  /* udf function calls stack */

  /* 
    This is a copy of the original JOIN USING list that comes from
    the parser. The parser :
      1. Sets the natural_join of the second TABLE_LIST in the join
         and the st_select_lex::prev_join_using.
      2. Makes a parent TABLE_LIST and sets its is_natural_join/
       join_using_fields members.
      3. Uses the wrapper TABLE_LIST as a table in the upper level.
    We cannot assign directly to join_using_fields in the parser because
    at stage (1.) the parent TABLE_LIST is not constructed yet and
    the assignment will override the JOIN USING fields of the lower level
    joins on the right.
  */
  List<String> *prev_join_using;
  /**
    The set of those tables whose fields are referenced in the select list of
    this select level.
  */
  table_map select_list_tables;
  /// First select_lex removed as part of some transformation, or NULL
  st_select_lex *removed_select;

  void init_query();
  void init_select();
  st_select_lex_unit* master_unit();
  st_select_lex_unit* first_inner_unit()
  { 
    return (st_select_lex_unit*) slave; 
  }
  st_select_lex* outer_select();
  st_select_lex* next_select() { return (st_select_lex*) next; }

  st_select_lex* last_select() 
  { 
    st_select_lex* mylast= this;
    for (; mylast->next_select(); mylast= mylast->next_select())
    {}
    return mylast; 
  }

  st_select_lex* next_select_in_list() 
  {
    return (st_select_lex*) link_next;
  }
  st_select_lex_node** next_select_in_list_addr()
  {
    return &link_next;
  }
  void invalidate();
  void mark_as_dependent(st_select_lex *last);

  bool set_braces(bool value);
  bool inc_in_sum_expr();
  uint get_in_sum_expr();

  bool add_item_to_list(THD *thd, Item *item);
  bool add_group_to_list(THD *thd, Item *item, bool asc);
  bool add_ftfunc_to_list(Item_func_match *func);
  bool add_order_to_list(THD *thd, Item *item, bool asc);
  bool add_gorder_to_list(THD *thd, Item *item, bool asc);
  TABLE_LIST* add_table_to_list(THD *thd, Table_ident *table,
				LEX_STRING *alias,
				ulong table_options,
				thr_lock_type flags= TL_UNLOCK,
                                enum_mdl_type mdl_type= MDL_SHARED_READ,
				List<Index_hint> *hints= 0,
                                List<String> *partition_names= 0,
                                LEX_STRING *option= 0);
  TABLE_LIST* get_table_list();
  bool init_nested_join(THD *thd);
  TABLE_LIST *end_nested_join(THD *thd);
  TABLE_LIST *nest_last_join(THD *thd);
  void add_joined_table(TABLE_LIST *table);
  TABLE_LIST *convert_right_join();
  List<Item>* get_item_list();
  ulong get_table_join_options();
  void set_lock_for_tables(thr_lock_type lock_type);
  inline void init_order()
  {
    order_list.elements= 0;
    order_list.first= 0;
    order_list.next= &order_list.first;
  }
  /*
    This method created for reiniting LEX in mysql_admin_table() and can be
    used only if you are going remove all SELECT_LEX & units except belonger
    to LEX (LEX::unit & LEX::select, for other purposes there are
    SELECT_LEX_UNIT::exclude_level & SELECT_LEX_UNIT::exclude_tree
  */
  void cut_subtree() { slave= 0; }
  bool test_limit();

  friend void lex_start(THD *thd);
  st_select_lex() : group_list_ptrs(NULL), order_list_ptrs(NULL),
    n_sum_items(0), n_child_sum_items(0),
    cur_pos_in_all_fields(ALL_FIELDS_UNDEF_POS)
  {}
  void make_empty_select()
  {
    init_query();
    init_select();
  }
  bool setup_ref_array(THD *thd, uint order_group_num);
  void print(THD *thd, String *str, enum_query_type query_type);
  static void print_order(String *str,
                          ORDER *order,
                          enum_query_type query_type);
  void print_limit(THD *thd, String *str, enum_query_type query_type);
  void fix_prepare_information(THD *thd, Item **conds, Item **having_conds);
  /*
    Destroy the used execution plan (JOIN) of this subtree (this
    SELECT_LEX and all nested SELECT_LEXes and SELECT_LEX_UNITs).
  */
  bool cleanup();
  bool cleanup_level();
  /*
    Recursively cleanup the join of this select lex and of all nested
    select lexes.
  */
  void cleanup_all_joins(bool full);

  void set_index_hint_type(enum index_hint_type type, index_clause_map clause);

  /* 
   Add a index hint to the tagged list of hints. The type and clause of the
   hint will be the current ones (set by set_index_hint()) 
  */
  bool add_index_hint (THD *thd, char *str, uint length);

  /* make a list to hold index hints */
  void alloc_index_hints (THD *thd);
  /* read and clear the index hints */
  List<Index_hint>* pop_index_hints(void) 
  {
    List<Index_hint> *hints= index_hints;
    index_hints= NULL;
    return hints;
  }

  void clear_index_hints(void) { index_hints= NULL; }
  bool handle_derived(LEX *lex, bool (*processor)(THD*, LEX*, TABLE_LIST*));
  bool is_part_of_union() { return master_unit()->is_union(); }

  /*
    For MODE_ONLY_FULL_GROUP_BY we need to maintain two flags:
     - Non-aggregated fields are used in this select.
     - Aggregate functions are used in this select.
    In MODE_ONLY_FULL_GROUP_BY only one of these may be true.
  */
  bool non_agg_field_used() const { return m_non_agg_field_used; }
  bool agg_func_used()      const { return m_agg_func_used; }

  void set_non_agg_field_used(bool val) { m_non_agg_field_used= val; }
  void set_agg_func_used(bool val)      { m_agg_func_used= val; }

  /// Lookup for SELECT_LEX type
  type_enum type(const THD *thd);

  /// Lookup for a type string
  const char *get_type_str(const THD *thd) { return type_str[type(thd)]; }
  static const char *get_type_str(type_enum type) { return type_str[type]; }

  bool is_dependent() const { return uncacheable & UNCACHEABLE_DEPENDENT; }
  bool is_cacheable() const
  {
    // drop UNCACHEABLE_EXPLAIN, because it is for internal usage only
    return !(uncacheable & ~UNCACHEABLE_EXPLAIN);
  }
  
private:
  bool m_non_agg_field_used;
  bool m_agg_func_used;

  /* current index hint kind. used in filling up index_hints */
  enum index_hint_type current_index_hint_type;
  index_clause_map current_index_hint_clause;
  /* a list of USE/FORCE/IGNORE INDEX */
  List<Index_hint> *index_hints;

  static const char *type_str[SLT_total];
};
```