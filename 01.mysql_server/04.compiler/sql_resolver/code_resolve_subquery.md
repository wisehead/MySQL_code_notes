#1.resolve_subquery

```
JOIN::prepare
--resolve_subquery
```

#2.comments

```cpp
/**
  @brief Resolve predicate involving subquery

  @param thd     Pointer to THD.
  @param join    Join that is part of a subquery predicate.

  @retval FALSE  Success.
  @retval TRUE   Error.

  @details
  Perform early unconditional subquery transformations:
   - Convert subquery predicate into semi-join, or
   - Mark the subquery for execution using materialization, or
   - Perform IN->EXISTS transformation, or
   - Perform more/less ALL/ANY -> MIN/MAX rewrite
   - Substitute trivial scalar-context subquery with its value

  @todo for PS, make the whole block execute only on the first execution

*/
```