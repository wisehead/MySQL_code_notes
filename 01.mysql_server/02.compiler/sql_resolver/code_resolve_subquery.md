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

#3.full flow

```cpp
/*
resolve_subquery函数用于对子查询进行预先判断，如果可以用半连接优化，则保存信息，
待JOIN.optimizer方法调用flatten_subqueries函数时，执行优化操作。
可优化的方式如下：
❏转换子查询为半连接。
❏使用物化标识子查询。
❏执行IN向EXISTS转换。
❏执行＜op＞ALL/ANY/SOME向MIN/MAX转换，op为大于或小于操作。
❏使用值替代标量子查询。
*/
static bool resolve_subquery(THD *thd, JOIN *join)
{...
        if (in_predicate) //子查询,IN操作
        {...
                //如果IN子查询的左操作符和右操作符不匹配,报错退出本函数。不匹配如：
                //(oe1, oe2) IN (SELECT ie1, ie2, ie3 ...),左操作数为2个,右操作数为3个,个数不匹配
                if (select_lex-＞item_list.elements != in_predicate-＞left_expr-＞cols())
                {
                        my_error(ER_OPERAND_COLUMNS, MYF(0), in_predicate-＞left_expr-＞cols());
                        DBUG_RETURN(TRUE);
                }
        }
...
        /*
          子查询优化点，重要注释：说明了可以被优化的子查询的类型,共10类,满足这10种情况,子查询可以被扁平化为半连接操作。在本函数中,只是把符合优化情况的保存起来,等到JOIN.optimizer方法调用flatten_subqueries函数时,再进行真正的优化动作。
          Check if we're in subquery that is a candidate for flattening into a
          semi-join (which is done in flatten_subqueries()). The requirements are:
                1. Subquery predicate is an IN/=ANY subquery predicate
                2. Subquery is a single SELECT (not a UNION)
                3. Subquery does not have GROUP BY
                4. Subquery does not use aggregate functions or HAVING
                5. Subquery predicate is at the AND-top-level of ON/WHERE clause
                6. We are not in a subquery of a single table UPDATE/DELETE that
                        doesn't have a JOIN (TODO: We should handle this at some
                        point by switching to multi-table UPDATE/DELETE)
                7. We're not in a confluent table-less subquery, like “SELECT 1”.
                8. No execution method was already chosen (by a prepared statement)
                9. Parent select is not a confluent table-less select
                10. Neither parent nor child select have STRAIGHT_JOIN option.
        */
        if (thd-＞optimizer_switch_flag(OPTIMIZER_SWITCH_SEMIJOIN) &&
                in_predicate &&                                                // 1
                !select_lex-＞is_part_of_union() &&                                // 2
                !select_lex-＞group_list.elements &&                                // 3
                !join-＞having && !select_lex-＞with_sum_func &&                        // 4
                (outer-＞resolve_place == st_select_lex::RESOLVE_CONDITION ||        // 5
                 outer-＞resolve_place == st_select_lex::RESOLVE_JOIN_NEST) &&        // 5
                outer-＞join &&                                                // 6
                select_lex-＞master_unit()-＞first_select()-＞leaf_tables &&                // 7
                in_predicate-＞exec_method == Item_exists_subselect::EXEC_UNSPECIFIED && // 8
                outer-＞leaf_tables &&                                        // 9
                !((join-＞select_options | outer-＞join-＞select_options)
                        & SELECT_STRAIGHT_JOIN))                                // 10
        {...
                        in_predicate-＞embedding_join_nest= outer-＞resolve_nest;
                        /* 如果可以用半连接优化,则调用push_back保存,待flatten_subqueries函数被调用时,执行优化操作 */
                        outer-＞join-＞sj_subselects.push_back(in_predicate);
                        chose_semijoin= true;
        }
...
        /* 如果不可以用半连接优化,调用select_transformer进行子查询的优化(应对IN/ALL/ANY/EXISTS等类型子查询) */
        if (!chose_semijoin && ubq_predicate-＞select_transformer(join) == Item_subselect::RES_ERROR)
                        DBUG_RETURN(TRUE);
...
}

```

#4.caller

```
❏Item_subselect.select_transformer是父类Item_subselect的一个方法，
被resolve_subquery函数调用。

❏Item_subselect.select_transformer被4个子类Item_singlerow_subselect、
Item_in_subselect、Item_allany_subselect、Item_exists_subselect继承，
根据具体的类型实现各自的优化。

❏resolve_subquery被JOIN.prepare调用，完成子查询优化。

```