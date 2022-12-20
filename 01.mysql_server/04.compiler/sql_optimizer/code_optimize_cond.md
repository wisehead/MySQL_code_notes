#1.optimize_cond

```
JOIN::optimize
--optimize_cond
```

#2.comments

```cpp
/**
  Optimize conditions by 

     a) applying transitivity to build multiple equality predicates
        (MEP): if x=y and y=z the MEP x=y=z is built. 
     b) apply constants where possible. If the value of x is known to be
        42, x is replaced with a constant of value 42. By transitivity, this
        also applies to MEPs, so the MEP in a) will become 42=x=y=z.
     c) remove conditions that are impossible or always true
  
  @param      join         pointer to the structure providing all context info
                           for the query
  @param      conds        conditions to optimize
  @param      join_list    list of join tables to which the condition
                           refers to
  @param[out] cond_value   Not changed if conds was empty 
                           COND_TRUE if conds is always true
                           COND_FALSE if conds is impossible
                           COND_OK otherwise

  @return optimized conditions
*/
```