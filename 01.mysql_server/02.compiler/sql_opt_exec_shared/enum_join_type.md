#1.enum join_type

```cpp
/*
  The structs which holds the join connections and join states
*/
enum join_type { /*
                   Initial state. Access type has not yet been decided
                   for the table
                 */
                 JT_UNKNOWN,
                 /* Table has exactly one row */
                 JT_SYSTEM,
                 /*
                   Table has at most one matching row. Values read
                   from this row can be treated as constants. Example:
                   "WHERE table.pk = 3"
                  */
                 JT_CONST,
                 /*
                   '=' operator is used on unique index. At most one
                   row is read for each combination of rows from
                   preceding tables
                 */
                 JT_EQ_REF,
                 /*
                   '=' operator is used on non-unique index
                 */
                 JT_REF,
                 /*
                   Full table scan.
                 */
                 JT_ALL,
                 /*
                   Range scan.
                 */
                 JT_RANGE,
                 /*
                   Like table scan, but scans index leaves instead of
                   the table
                 */
                 JT_INDEX_SCAN,
                 /* Fulltext index is used */
                 JT_FT,
                 /*
                   Like ref, but with extra search for NULL values.
                   E.g. used for "WHERE col = ... OR col IS NULL"
                  */
                 JT_REF_OR_NULL,
                 /*
                   Like eq_ref for subqueries: Replaces subquery with
                   index lookup in unique index
                  */
                 JT_UNIQUE_SUBQUERY,
                 /*
                   Like unique_subquery but for non-unique index
                 */
                 JT_INDEX_SUBQUERY,
                 /*
                   Do multiple range scans over one table and combine
                   the results into one. The merge can be used to
                   produce unions and intersections
                 */
                 JT_INDEX_MERGE};
                 
```