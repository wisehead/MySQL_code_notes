#1.JOIN::flatten_subqueries

```
JOIN::optimize
--JOIN::flatten_subqueries
```

#2.full code

```cpp
/*
flatten_subqueries函数对可以对半连接的子查询进行转换，即把子查询的表对象上拉到FROM子句，把FROM子句原先的表对象和子查询中被上拉的表对象进行半连接操作。这种转换称为“扁平化子查询”。
*/
bool JOIN::flatten_subqueries()
{...
        /* 第一步, 从底层向上,先转换各子句中存在的子查询 */
        for (subq= sj_subselects.begin(), subq_end= sj_subselects.end();
                subq ＜ subq_end;
                subq++)
        {
                //功能限制：到MySQL V5.6.10为止,只支持IN格式的子查询转为半连接
                DBUG_ASSERT((*subq)-＞substype() == Item_subselect::IN_SUBS);
                //获得子句中的查询语句
                st_select_lex *child_select= (*subq)-＞unit-＞first_select();
                JOIN *child_join= child_select-＞join;
                child_select-＞where= child_join-＞conds;
                if (child_join-＞flatten_subqueries())//递归处理：扁平化子句中的子查询
                        DBUG_RETURN(TRUE);
...
        } //for (subq= sj_subselects.begin()...结束
        /*
          第二步：对子查询进行转换:
                  转换前,对子查询数组(多个子查询)进行排序,排序的方式是：
                  1) 相关子查询比不相关子查询靠前
                  2) 有更多外表的子查询靠前
        */
        my_qsort(sj_subselects.begin(),
                   sj_subselects.size(), sj_subselects.element_size(),
                   reinterpret_cast＜qsort_cmp＞(subq_sj_candidate_cmp));
        Prepared_stmt_arena_holder ps_arena_holder(thd);
        // #tables-in-parent-query + #tables-in-subquery + sj nests ＜= MAX_TABLES
        /* Replace all subqueries to be flattened with Item_int(1) */
        uint table_count= tables;
        //对排好序的所有子查询进行转换前的准备——条件替换
        for (subq= sj_subselects.begin(); subq ＜ subq_end; subq++)
        {
                // Add the tables in the subquery nest plus one in case of materialization:
                const uint tables_added= (*subq)-＞unit-＞first_select()-＞join-＞tables + 1;
                (*subq)-＞sj_chosen= table_count + tables_added ＜= MAX_TABLES;
                if (!(*subq)-＞sj_chosen)
                        continue;
                table_count+= tables_added;
                Item **tree= ((*subq)-＞embedding_join_nest == NULL) ?
                                   &conds : ((*subq)-＞embedding_join_nest-＞join_cond_ref());
                if (replace_subcondition(this, tree, *subq, new Item_int(1), FALSE))
                        DBUG_RETURN(TRUE); /* purecov: inspected */
        }
        //对排好序的所有子查询进行转换
        for (subq= sj_subselects.begin(); subq ＜ subq_end; subq++)
        {...
                /* 处理IN_SUBS类型的子查询为半连接操作,其他类型的子查询不予处理 */
                if (convert_subquery_to_semijoin(this, *subq))
                        DBUG_RETURN(TRUE);
        }
        /* 第三步：对于第二步之后不能通过convert_subquery_to_semijoin函数处理的子查询,把IN转换为EXISTS格式 */
        for (subq= sj_subselects.begin(); subq ＜ subq_end; subq++)
        {...
                JOIN *child_join= (*subq)-＞unit-＞first_select()-＞join;
...
                //实现每个子句中的子查询的优化
                res= (*subq)-＞select_transformer(child_join);
...
                // IN转换为EXISTS格式
                if (replace_subcondition(this, tree, *subq, substitute, do_fix_fields))
                        DBUG_RETURN(TRUE);
...
        }
...
}
```

#3.comments

```cpp
/*
  Convert semi-join subquery predicates into semi-join join nests

  SYNOPSIS
    JOIN::flatten_subqueries()
 
  DESCRIPTION

    Convert candidate subquery predicates into semi-join join nests. This 
    transformation is performed once in query lifetime and is irreversible.
    
    Conversion of one subquery predicate
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    We start with a join that has a semi-join subquery:

      SELECT ...
      FROM ot, ...
      WHERE oe IN (SELECT ie FROM it1 ... itN WHERE subq_where) AND outer_where

    and convert it into a semi-join nest:

      SELECT ...
      FROM ot SEMI JOIN (it1 ... itN), ...
      WHERE outer_where AND subq_where AND oe=ie

    that is, in order to do the conversion, we need to 

     * Create the "SEMI JOIN (it1 .. itN)" part and add it into the parent
       query's FROM structure.
     * Add "AND subq_where AND oe=ie" into parent query's WHERE (or ON if
       the subquery predicate was in an ON expression)
     * Remove the subquery predicate from the parent query's WHERE

    Considerations when converting many predicates
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    A join may have at most MAX_TABLES tables. This may prevent us from
    flattening all subqueries when the total number of tables in parent and
    child selects exceeds MAX_TABLES. In addition, one slot is reserved per
    semi-join nest, in case the subquery needs to be materialized in a
    temporary table.
    We deal with this problem by flattening children's subqueries first and
    then using a heuristic rule to determine each subquery predicate's
    "priority".

  RETURN 
    FALSE  OK
    TRUE   Error
*/
```