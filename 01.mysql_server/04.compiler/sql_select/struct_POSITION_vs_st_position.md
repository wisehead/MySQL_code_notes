#1.st_position(POSITION)

```cpp
/**
  A position of table within a join order. This structure is primarily used
  as a part of join->positions and join->best_positions arrays.

  One POSITION element contains information about:
   - Which table is accessed
   - Which access method was chosen
      = Its cost and #of output records
   - Semi-join strategy choice. Note that there are two different
     representation formats:
      1. The one used during join optimization
      2. The one used at plan refinement/code generation stage.
      We call fix_semijoin_strategies_for_picked_join_order() to switch
      between #1 and #2. See that function's comment for more details.

   - Semi-join optimization state. When we're running join optimization,
     we main a state for every semi-join strategy which are various
     variables that tell us if/at which point we could consider applying the
     strategy.
     The variables are really a function of join prefix but they are too
     expensive to re-caclulate for every join prefix we consider, so we
     maintain current state in join->positions[#tables_in_prefix]. See
     advance_sj_state() for details.

  This class has to stay a POD, because it is memcpy'd in many places.
*/

typedef struct st_position : public Sql_alloc
{
  /*
    The "fanout" -  number of output rows that will be produced (after
    pushed down selection condition is applied) per each row combination of
    previous tables.
  */
  double records_read;

  /*
    Cost accessing the table in course of the entire complete join execution,
    i.e. cost of one access method use (e.g. 'range' or 'ref' scan ) times
    number the access method will be invoked.
  */
  double read_time;
  JOIN_TAB *table;

  /*
    NULL  -  'index' or 'range' or 'index_merge' or 'ALL' access is used.
    Other - [eq_]ref[_or_null] access is used. Pointer to {t.keypart1 = expr}
  */
  Key_use *key;

  /* If ref-based access is used: bitmap of tables this table depends on  */
  table_map ref_depend_map;
  bool use_join_buffer;

  /* These form a stack of partial join order costs and output sizes */
  Cost_estimate prefix_cost;
  double    prefix_record_count;

  /*
    Current optimization state: Semi-join strategy to be used for this
    and preceding join tables.

    Join optimizer sets this for the *last* join_tab in the
    duplicate-generating range. That is, in order to interpret this field,
    one needs to traverse join->[best_]positions array from right to left.
    When you see a join table with sj_strategy!= SJ_OPT_NONE, some other
    field (depending on the strategy) tells how many preceding positions
    this applies to. The values of covered_preceding_positions->sj_strategy
    must be ignored.
  */
  uint sj_strategy;
  /*
    Valid only after fix_semijoin_strategies_for_picked_join_order() call:
    if sj_strategy!=SJ_OPT_NONE, this is the number of subsequent tables that
    are covered by the specified semi-join strategy
  */
  uint n_sj_tables;

  /**
    Bitmap of semi-join inner tables that are in the join prefix and for
    which there's no provision yet for how to eliminate semi-join duplicates
    which they produce.
  */
  table_map dups_producing_tables;

/* LooseScan strategy members */

  /* The first (i.e. driving) table we're doing loose scan for */
  uint        first_loosescan_table;
  /*
     Tables that need to be in the prefix before we can calculate the cost
     of using LooseScan strategy.
  */
  table_map   loosescan_need_tables;

  /*
    keyno  -  Planning to do LooseScan on this key. If keyuse is NULL then
              this is a full index scan, otherwise this is a ref+loosescan
              scan (and keyno matches the KEUSE's)
    MAX_KEY - Not doing a LooseScan
  */
  uint loosescan_key;  // final (one for strategy instance )
  uint loosescan_parts; /* Number of keyparts to be kept distinct */
/* FirstMatch strategy */
  /*
    Index of the first inner table that we intend to handle with this
    strategy
  */
  uint first_firstmatch_table;
  /*
    Tables that were not in the join prefix when we've started considering
    FirstMatch strategy.
  */
  table_map first_firstmatch_rtbl;
  /*
    Tables that need to be in the prefix before we can calculate the cost
    of using FirstMatch strategy.
   */
  table_map firstmatch_need_tables;

/* Duplicate Weedout strategy */
  /* The first table that the strategy will need to handle */
  uint  first_dupsweedout_table;
  /*
    Tables that we will need to have in the prefix to do the weedout step
    (all inner and all outer that the involved semi-joins are correlated with)
  */
  table_map dupsweedout_tables;

/* SJ-Materialization-Scan strategy */
  /* The last inner table (valid once we're after it) */
  uint      sjm_scan_last_inner;
  /*
    Tables that we need to have in the prefix to calculate the correct cost.
    Basically, we need all inner tables and outer tables mentioned in the
    semi-join's ON expression so we can correctly account for fanout.
  */
  table_map sjm_scan_need_tables;
} POSITION;      
```