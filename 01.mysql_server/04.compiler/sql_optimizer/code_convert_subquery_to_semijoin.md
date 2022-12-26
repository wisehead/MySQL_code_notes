#1.convert_subquery_to_semijoin

```cpp
JOIN.optimize
--flatten_subqueries
----convert_subquery_to_semijoin

```

#2.comments

```cpp
/**
  Convert a subquery predicate into a TABLE_LIST semi-join nest

  @param parent_join Parent join, which has subq_pred in its WHERE/ON clause.
  @param subq_pred   Subquery predicate to be converted.
                     This is either an IN, =ANY or EXISTS predicate.

  @retval FALSE OK
  @retval TRUE  Error

  @details

  The following transformations are performed:

  1. IN/=ANY predicates on the form:

  SELECT ...
  FROM ot1 ... otN
  WHERE (oe1, ... oeM) IN (SELECT ie1, ..., ieM)
                           FROM it1 ... itK
                          [WHERE inner-cond])
   [AND outer-cond]
  [GROUP BY ...] [HAVING ...] [ORDER BY ...]

  are transformed into:

  SELECT ...
  FROM (ot1 ... otN) SJ (it1 ... itK)
                     ON (oe1, ... oeM) = (ie1, ..., ieM)
                        [AND inner-cond]
  [WHERE outer-cond]
  [GROUP BY ...] [HAVING ...] [ORDER BY ...]

  Notice that the inner-cond may contain correlated and non-correlated
  expressions. Further transformations will analyze and break up such
  expressions.

  Prepared Statements: the transformation is permanent:
   - Changes in TABLE_LIST structures are naturally permanent
   - Item tree changes are performed on statement MEM_ROOT:
      = we activate statement MEM_ROOT 
      = this function is called before the first fix_prepare_information call.

  This is intended because the criteria for subquery-to-sj conversion remain
  constant for the lifetime of the Prepared Statement.
*/

```