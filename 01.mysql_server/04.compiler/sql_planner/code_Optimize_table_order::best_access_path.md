#1. Optimize_table_order::best_access_path

```
JOIN::optimize
make_join_statistics
--Optimize_table_order::choose_table_order
----Optimize_table_order::optimize_straight_join
------Optimize_table_order::best_access_path
```

#2.comments

```cpp
/**
  Find the best access path for an extension of a partial execution
  plan and add this path to the plan.

  The function finds the best access path to table 's' from the passed
  partial plan where an access path is the general term for any means to
  access the data in 's'. An access path may use either an index or a scan,
  whichever is cheaper. The input partial plan is passed via the array
  'join->positions' of length 'idx'. The chosen access method for 's' and its
  cost are stored in 'join->positions[idx]'.

  @param s                the table to be joined by the function
  @param thd              thread for the connection that submitted the query
  @param remaining_tables set of tables not included in the partial plan yet.
  @param idx              the length of the partial plan
  @param disable_jbuf     TRUE<=> Don't use join buffering
  @param record_count     estimate for the number of records returned by the
                          partial plan
  @param[out] pos         Table access plan
  @param[out] loose_scan_pos  Table plan that uses loosescan, or set cost to 
                              DBL_MAX if not possible.
*/
```