#1.make_join_statistics

```
JOIN::optimize
--make_join_statistics
```

#2.comments
```cpp
/**
  Calculate best possible join order and initialize the join structure.

  @param  join          Join object that is populated with statistics data
  @param  tables_arg    List of tables that is referenced by this query 
  @param  conds         Where condition of query
  @param  keyuse_array[out] Populated with key_use information  
  @param  first_optimization True if first optimization of this query

  @return true if success, false if error

  @details
  Here is an overview of the logic of this function:

  - Initialize JOIN data structures and setup basic dependencies between tables.

  - Update dependencies based on join information.

  - Make key descriptions (update_ref_and_keys()).

  - Pull out semi-join tables based on table dependencies.

  - Extract tables with zero or one rows as const tables.

  - Read contents of const tables, substitute columns from these tables with
    actual data. Also keep track of empty tables vs. one-row tables. 

  - After const table extraction based on row count, more tables may
    have become functionally dependent. Extract these as const tables.

  - Add new sargable predicates based on retrieved const values.

  - Calculate number of rows to be retrieved from each table.

  - Calculate cost of potential semi-join materializations.

  - Calculate best possible join order based on available statistics.

  - Fill in remaining information for the generated join order.
*/
```