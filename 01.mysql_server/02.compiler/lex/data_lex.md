#<center>sql lex结构</center>

#1.struct LEX

```cpp
//sql_lex.h
/* The state of the lex parsing. This is saved in the THD struct */

struct LEX: public Query_tables_list
{
  SELECT_LEX_UNIT unit;                         /* most upper unit */
  SELECT_LEX select_lex;                        /* first SELECT_LEX */
...
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
}

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
