#1.struct st_nested_join

```cpp
/**
  Struct st_nested_join is used to represent how tables are connected through
  outer join operations and semi-join operations to form a query block.
  Out of the parser, inner joins are also represented by st_nested_join
  structs, but these are later flattened out by simplify_joins().
  Some outer join nests are also flattened, when it can be determined that
  they can be processed as inner joins instead of outer joins.
*/
typedef struct st_nested_join
{
  st_nested_join() { memset(this, 0, sizeof(*this)); }

  List<TABLE_LIST>  join_list;       /* list of elements in the nested join */
  table_map         used_tables;     /* bitmap of tables in the nested join */
  table_map         not_null_tables; /* tables that rejects nulls           */
  /**
    Used for pointing out the first table in the plan being covered by this
    join nest. It is used exclusively within make_outerjoin_info().
   */
  plan_idx first_nested;
  /**
    Set to true when natural join or using information has been processed.
  */
  bool natural_join_processed;
  /**
    Number of tables and outer join nests administered by this nested join
    object for the sake of cost analysis. Includes direct member tables as
    well as tables included through semi-join nests, but notice that semi-join
    nests themselves are not counted.
  */
  uint              nj_total;
  /**
    Used to count tables in the nested join in 2 isolated places:
    1. In make_outerjoin_info(). 
    2. check_interleaving_with_nj/backout_nj_state (these are called
       by the join optimizer. 
    Before each use the counters are zeroed by SELECT_LEX::reset_nj_counters.
  */
  uint              nj_counter;
  /**
    Bit identifying this nested join. Only nested joins representing the
    outer join structure need this, other nests have bit set to zero.
  */
  nested_join_map   nj_map;
  /**
    Tables outside the semi-join that are used within the semi-join's
    ON condition (ie. the subquery WHERE clause and optional IN equalities).
  */
  table_map         sj_depends_on;
  /**
    Outer non-trivially correlated tables, a true subset of sj_depends_on
  */
  table_map         sj_corr_tables;
  /**
    Query block id if this struct is generated from a subquery transform.
  */
  uint query_block_id;

  /// Bitmap of which strategies are enabled for this semi-join nest
  uint sj_enabled_strategies;

  /*
    Lists of trivially-correlated expressions from the outer and inner tables
    of the semi-join, respectively.
  */
  List<Item>        sj_outer_exprs, sj_inner_exprs;
  Semijoin_mat_optimize sjm;
} NESTED_JOIN;

```