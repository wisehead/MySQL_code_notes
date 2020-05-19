#<center>sql lex结构</center>

#1.struct LEX

```cpp
//sql_lex.h
/* The state of the lex parsing. This is saved in the THD struct */

struct LEX: public Query_tables_list
{
  SELECT_LEX_UNIT unit;                         /* most upper unit */
  SELECT_LEX select_lex;                        /* first SELECT_LEX */
  /* current SELECT_LEX in parsing */
  SELECT_LEX *current_select;
  /* list of all SELECT_LEX */
  SELECT_LEX *all_selects_list;

  char *length,*dec,*change;
  LEX_STRING name;
  char *help_arg;
  char* to_log;                                 /* For PURGE MASTER LOGS TO */
  char* x509_subject,*x509_issuer,*ssl_cipher;
  String *wild;
  sql_exchange *exchange;
  select_result *result;
  Item *default_value, *on_update_value;
  LEX_STRING comment, ident;
  LEX_USER *grant_user;
  XID *xid;
  THD *thd;

  /* maintain a list of used plugins for this LEX */
  DYNAMIC_ARRAY plugins;
  plugin_ref plugins_static_buffer[INITIAL_LEX_PLUGIN_LIST_SIZE];

  const CHARSET_INFO *charset;
  bool text_string_is_7bit;
  /* store original leaf_tables for INSERT SELECT and PS/SP */
  TABLE_LIST *leaf_tables_insert;

  /** SELECT of CREATE VIEW statement */
  LEX_STRING create_view_select;

  /** Start of 'ON table', in trigger statements.  */
  const char* raw_trg_on_table_name_begin;
  /** End of 'ON table', in trigger statements. */
  const char* raw_trg_on_table_name_end;

  /* Partition info structure filled in by PARTITION BY parse part */
  partition_info *part_info;

  /*
    The definer of the object being created (view, trigger, stored routine).
    I.e. the value of DEFINER clause.
  */
  LEX_USER *definer;

  List<Key_part_spec> col_list;
  List<Key_part_spec> ref_list;
  /*
    A list of strings is maintained to store the SET clause command user strings
    which are specified in load data operation.  This list will be used
    during the reconstruction of "load data" statement at the time of writing
    to binary log.
   */
  List<String>        load_set_str_list;
  List<String>        interval_list;
  List<LEX_USER>      users_list;
  List<LEX_COLUMN>    columns;
  List<Item>          *insert_list,field_list,value_list,update_list;
  List<List_item>     many_values;
  List<set_var_base>  var_list;
  List<Item_func_set_user_var> set_var_list; // in-query assignment list
  List<Item_param>    param_list;
  List<LEX_STRING>    view_list; // view list (list of field names in view)
  /*
    A stack of name resolution contexts for the query. This stack is used
    at parse time to set local name resolution contexts for various parts
    of a query. For example, in a JOIN ... ON (some_condition) clause the
    Items in 'some_condition' must be resolved only against the operands
    of the the join, and not against the whole clause. Similarly, Items in
    subqueries should be resolved against the subqueries (and outer queries).
    The stack is used in the following way: when the parser detects that
    all Items in some clause need a local context, it creates a new context
    and pushes it on the stack. All newly created Items always store the
    top-most context in the stack. Once the parser leaves the clause that
    required a local context, the parser pops the top-most context.
  */
  List<Name_resolution_context> context_stack;

  /**
    Argument values for PROCEDURE ANALYSE(); is NULL for other queries
  */
  Proc_analyse_params *proc_analyse;
  SQL_I_List<TABLE_LIST> auxiliary_table_list, save_list;
  Create_field        *last_field;
  Item_sum *in_sum_func;
  udf_func udf;
  HA_CHECK_OPT   check_opt;         // check/repair options
  HA_CREATE_INFO create_info;
  KEY_CREATE_INFO key_create_info;
  LEX_MASTER_INFO mi;               // used by CHANGE MASTER
  LEX_SLAVE_CONNECTION slave_connection;
  LEX_SERVER_OPTIONS server_options;
  USER_RESOURCES mqh;
  LEX_RESET_SLAVE reset_slave_info;
  ulong type;
  /*
    This variable is used in post-parse stage to declare that sum-functions,
    or functions which have sense only if GROUP BY is present, are allowed.
    For example in a query
    SELECT ... FROM ...WHERE MIN(i) == 1 GROUP BY ... HAVING MIN(i) > 2
    MIN(i) in the WHERE clause is not allowed in the opposite to MIN(i)
    in the HAVING clause. Due to possible nesting of select construct
    the variable can contain 0 or 1 for each nest level.
  */
  nesting_map allow_sum_func;

  Sql_cmd *m_sql_cmd;

  /*
    Usually `expr` rule of yacc is quite reused but some commands better
    not support subqueries which comes standard with this rule, like
    KILL, HA_READ, CREATE/ALTER EVENT etc. Set this to `false` to get
    syntax error back.
  */
  bool expr_allows_subselect;

  enum SSL_type ssl_type;           /* defined in violite.h */
  enum enum_duplicates duplicates;
  enum enum_tx_isolation tx_isolation;
  enum xa_option_words xa_opt;
  enum enum_var_type option_type;
  enum enum_view_create_mode create_view_mode;
  enum enum_drop_mode drop_mode;

  uint profile_query_id;
  uint profile_options;
  uint uint_geom_type;
  uint grant, grant_tot_col, which_columns;
  enum Foreign_key::fk_match_opt fk_match_option;
  enum Foreign_key::fk_option fk_update_opt;
  enum Foreign_key::fk_option fk_delete_opt;
  uint slave_thd_opt, start_transaction_opt;
  int nest_level;
  uint8 describe;
  /*
    A flag that indicates what kinds of derived tables are present in the
    query (0 if no derived tables, otherwise a combination of flags
    DERIVED_SUBQUERY and DERIVED_VIEW).
  */
  uint8 derived_tables;
  uint8 create_view_algorithm;
  uint8 create_view_check;
  uint8 context_analysis_only;
  bool drop_if_exists, drop_temporary, local_file, one_shot_set;
  bool autocommit;
  bool verbose, no_write_to_binlog;

  enum enum_yes_no_unknown tx_chain, tx_release;
  bool safe_to_cache_query;
  bool subqueries, ignore;
  st_parsing_options parsing_options;
  Alter_info alter_info;
  /*
    For CREATE TABLE statement last element of table list which is not
    part of SELECT or LIKE part (i.e. either element for table we are
    creating or last of tables referenced by foreign keys).
  */
  TABLE_LIST *create_last_non_select_table;
  /* Prepared statements SQL syntax:*/
  LEX_STRING prepared_stmt_name; /* Statement name (in all queries) */
  /*
    Prepared statement query text or name of variable that holds the
    prepared statement (in PREPARE ... queries)
  */
  LEX_STRING prepared_stmt_code;
  /* If true, prepared_stmt_code is a name of variable that holds the query */
  bool prepared_stmt_code_is_varref;
  /* Names of user variables holding parameters (in EXECUTE) */
  List<LEX_STRING> prepared_stmt_params;
  sp_head *sphead;
  sp_name *spname;
  bool sp_lex_in_use;   /* Keep track on lex usage in SPs for error handling */
  bool all_privileges;
  bool proxy_priv;
  bool is_change_password;
  /*
    Temporary variable to distinguish SET PASSWORD command from others
    SQLCOM_SET_OPTION commands. Should be removed when WL#6409 is
    introduced.
  */
  bool is_set_password_sql;
  bool contains_plaintext_password;

private:
  bool m_broken; ///< see mark_broken()
  /// Current SP parsing context.
  /// @see also sp_head::m_root_parsing_ctx.
  sp_pcontext *sp_current_parsing_ctx;
public:
  st_sp_chistics sp_chistics;

  Event_parse_data *event_parse_data;

  bool only_view;       /* used for SHOW CREATE TABLE/VIEW */
  /*
    field_list was created for view and should be removed before PS/SP
    rexecuton
  */
  bool empty_field_list_on_rset;
  /*
    view created to be run from definer (standard behaviour)
  */
  uint8 create_view_suid;

  /*
    stmt_definition_begin is intended to point to the next word after
    DEFINER-clause in the following statements:
      - CREATE TRIGGER (points to "TRIGGER");
      - CREATE PROCEDURE (points to "PROCEDURE");
      - CREATE FUNCTION (points to "FUNCTION" or "AGGREGATE");
      - CREATE EVENT (points to "EVENT")

    This pointer is required to add possibly omitted DEFINER-clause to the
    DDL-statement before dumping it to the binlog.

    keyword_delayed_begin_offset is the offset to the beginning of the DELAYED
    keyword in INSERT DELAYED statement. keyword_delayed_end_offset is the
    offset to the character right after the DELAYED keyword.
  */
  union {
    const char *stmt_definition_begin;
    uint keyword_delayed_begin_offset;
  };

  union {
    const char *stmt_definition_end;
    uint keyword_delayed_end_offset;
  };

  /**
    During name resolution search only in the table list given by
    Name_resolution_context::first_name_resolution_table and
    Name_resolution_context::last_name_resolution_table
    (see Item_field::fix_fields()).
  */
  bool use_only_table_context;

  /*
    Reference to a struct that contains information in various commands
    to add/create/drop/change table spaces.
  */
  st_alter_tablespace *alter_tablespace_info;
  bool escape_used;
  bool is_lex_started; /* If lex_start() did run. For debugging. */

  /*
    The set of those tables whose fields are referenced in all subqueries
    of the query.
    TODO: possibly this it is incorrect to have used tables in LEX because
    with subquery, it is not clear what does the field mean. To fix this
    we should aggregate used tables information for selected expressions
    into the select_lex.
  */
  table_map  used_tables;

  class Explain_format *explain_format;          
}
```

#2. SELECT_LEX(st_select_lex)

```cpp
//sql_lex.h
typedef class st_select_lex SELECT_LEX;

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
  bool                is_item_list_lookup;
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
  bool  braces;     /* SELECT ... UNION (SELECT ... ) <- this braces */
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

#3. st_select_lex_unit

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
};    
```
