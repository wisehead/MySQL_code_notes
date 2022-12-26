#1.simplify_joins

```
JOIN::optimize
--simplify_joins
```

#2.code flow

```cpp
static COND *
simplify_joins(JOIN *join, List＜TABLE_LIST＞ *join_list, Item *conds, bool top,
                               bool in_sj, Item **new_conds, uint *changelog)
{
...
        while ((table= li++)) //第一部分：对连接处理,转换外连接为内连接
        {
                ...
                if ((nested_join= table-＞nested_join))
                {
                        if (table-＞join_cond()) //如果表上有连接条件表达式,消除其中可能的外连接
                        {
                                Item *join_cond= table-＞join_cond();
                                //递归调用simplify_joins的conds参数table-＞join_cond()
                                if (simplify_joins(join, &nested_join-＞join_list,
                                        join_cond, false, in_sj || table-＞sj_on_expr,
                                        &join_cond, changelog));
                                        DBUG_RETURN(true);
                                ...
                        }
...
                        //有嵌套连接存在,递归处理嵌套连接的情况。参数与前面的递归调用不同
                        if ( simplify_joins(join, &nested_join-＞join_list, conds, top,
                                           in_sj || table-＞sj_on_expr, &conds, changelog))
                                DBUG_RETURN(true);...
                } // if ((nested_join= table-＞nested_join))结束
                else{...}
                ...
                //如果是内表(a left join b,b为内表)
                if (!table-＞outer_join || (used_tables & not_null_tables))
                {...
                        /* 对于内接的内表,在WHERE或ON表达式上存在有包含连接谓词的嵌入式的嵌套连接,且有空值拒绝的条件在内表的列上,则这样的外连接可以被转换为内连接 */
                        if (table-＞join_cond())
                        {
                                //外连接转为内连接,代码中的实现是把条件放到WHERE子句的条件上
                                if (conds)
                                {
                                        Item_cond_and *new_cond=
                                                static_cast＜Item_cond_and*＞(and_conds(conds, table-＞join_cond()));
                                        ...
                                } else{...}
...
                        }
                } //对内表的处理结束
                /* 如果top为false,则循环继续执行,这意味着本轮次(本次函数被调用)第一个simplify_joins递归结束。即table上的table-＞on_expr被逐层处理完毕(因为可能有多层的嵌套)*/
                if (!top)
                        continue;
                //经过上面的代码处理后,如果表上还有表达式,则对应的是不可以再转换的外连接的内表
                if (table-＞on_expr){...}
...
        }//第一部分结束,遍历所有表结束
        /* 第二部分：可以转换为内连接的外连接全部处理完毕,扁平化可被扁平处理的连接,消除嵌套连接 */
        /* 没有连接条件且不是半连接的,都可以被扁平化处理 */
        while ((table= li++)) {...}
...
}
```

#3.comments

```cpp
/*
simplify_joins函数用于连接化简，其主要工作包括两个方面，一是外连接消除，二是嵌套连接消除。

外连接消除，把可以转换为内连接的外连接进行转换。对于以嵌套形式存在的外连接也进行处理。

具体优化方式参见如下情形一。嵌套连接消除，把一些用于表示嵌套的括号尽可能消除。

具体优化方式参见如下情形二。
*/
/**
  Simplify joins replacing outer joins by inner joins whenever it's
  possible.

    The function, during a retrieval of join_list,  eliminates those
    outer joins that can be converted into inner join, possibly nested.
    It also moves the join conditions for the converted outer joins
    and from inner joins to conds.
    The function also calculates some attributes for nested joins:
    - used_tables    
    - not_null_tables
    - dep_tables.
    - on_expr_dep_tables
    The first two attributes are used to test whether an outer join can
    be substituted for an inner join. The third attribute represents the
    relation 'to be dependent on' for tables. If table t2 is dependent
    on table t1, then in any evaluated execution plan table access to
    table t2 must precede access to table t2. This relation is used also
    to check whether the query contains  invalid cross-references.
    The forth attribute is an auxiliary one and is used to calculate
    dep_tables.
    As the attribute dep_tables qualifies possibles orders of tables in the
    execution plan, the dependencies required by the straight join
    modifiers are reflected in this attribute as well.
    The function also removes all braces that can be removed from the join
    expression without changing its meaning.

  @note
    An outer join can be replaced by an inner join if the where condition
    or the join condition for an embedding nested join contains a conjunctive
    predicate rejecting null values for some attribute of the inner tables.

    E.g. in the query:    
    @code
      SELECT * FROM t1 LEFT JOIN t2 ON t2.a=t1.a WHERE t2.b < 5
    @endcode
    the predicate t2.b < 5 rejects nulls.
    The query is converted first to:
    @code
      SELECT * FROM t1 INNER JOIN t2 ON t2.a=t1.a WHERE t2.b < 5
    @endcode
    then to the equivalent form:
    @code
      SELECT * FROM t1, t2 ON t2.a=t1.a WHERE t2.b < 5 AND t2.a=t1.a
    @endcode


    Similarly the following query:
    @code
      SELECT * from t1 LEFT JOIN (t2, t3) ON t2.a=t1.a t3.b=t1.b
        WHERE t2.c < 5  
    @endcode
    is converted to:
    @code
      SELECT * FROM t1, (t2, t3) WHERE t2.c < 5 AND t2.a=t1.a t3.b=t1.b 

    @endcode

    One conversion might trigger another:
    @code
      SELECT * FROM t1 LEFT JOIN t2 ON t2.a=t1.a
                       LEFT JOIN t3 ON t3.b=t2.b
        WHERE t3 IS NOT NULL =>
      SELECT * FROM t1 LEFT JOIN t2 ON t2.a=t1.a, t3
        WHERE t3 IS NOT NULL AND t3.b=t2.b => 
      SELECT * FROM t1, t2, t3
        WHERE t3 IS NOT NULL AND t3.b=t2.b AND t2.a=t1.a
  @endcode

    The function removes all unnecessary braces from the expression
    produced by the conversions.
    E.g.
    @code
      SELECT * FROM t1, (t2, t3) WHERE t2.c < 5 AND t2.a=t1.a AND t3.b=t1.b
    @endcode
    finally is converted to: 
    @code
      SELECT * FROM t1, t2, t3 WHERE t2.c < 5 AND t2.a=t1.a AND t3.b=t1.b

    @endcode


    It also will remove braces from the following queries:
    @code
      SELECT * from (t1 LEFT JOIN t2 ON t2.a=t1.a) LEFT JOIN t3 ON t3.b=t2.b
      SELECT * from (t1, (t2,t3)) WHERE t1.a=t2.a AND t2.b=t3.b.
    @endcode

    The benefit of this simplification procedure is that it might return 
    a query for which the optimizer can evaluate execution plan with more
    join orders. With a left join operation the optimizer does not
    consider any plan where one of the inner tables is before some of outer
    tables.

  IMPLEMENTATION
    The function is implemented by a recursive procedure.  On the recursive
    ascent all attributes are calculated, all outer joins that can be
    converted are replaced and then all unnecessary braces are removed.
    As join list contains join tables in the reverse order sequential
    elimination of outer joins does not require extra recursive calls.

  SEMI-JOIN NOTES
    Remove all semi-joins that have are within another semi-join (i.e. have
    an "ancestor" semi-join nest)

  EXAMPLES
    Here is an example of a join query with invalid cross references:
    @code
      SELECT * FROM t1 LEFT JOIN t2 ON t2.a=t3.a LEFT JOIN t3 ON t3.b=t1.b 
    @endcode

  @param join        reference to the query info
  @param join_list   list representation of the join to be converted
  @param conds       condition that join condition for converted outer joins
                     is added to
  @param top         true <=> conds is the where condition
  @param in_sj       TRUE <=> processing semi-join nest's children
  @param[out] new_conds New condition
  @param changelog   Don't specify this parameter, it is reserved for
                     recursive calls inside this function

  @returns true for error, false for success
*/

```