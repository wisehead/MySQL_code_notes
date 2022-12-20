#1.opt_sum_query

```
JOIN::optimize
--opt_sum_query
```

#2.comments

```cpp
/**
  Substitutes constants for some COUNT(), MIN() and MAX() functions.

  @param thd                   thread handler
  @param tables                list of leaves of join table tree
  @param all_fields            All fields to be returned
  @param conds                 WHERE clause

  @note
    This function is only called for queries with aggregate functions and no
    GROUP BY part. This means that the result set shall contain a single
    row only

  @retval
    0                    no errors
  @retval
    1                    if all items were resolved
  @retval
    HA_ERR_KEY_NOT_FOUND on impossible conditions
  @retval
    HA_ERR_... if a deadlock or a lock wait timeout happens, for example
  @retval
    ER_...     e.g. ER_SUBQUERY_NO_1_ROW
*/
```