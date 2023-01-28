#1.Item_in_subselect::single_value_in_to_exists_transformer

```cpp
Item_subselect::trans_res
Item_in_subselect::single_value_in_to_exists_transformer(JOIN * join, Comp_creator *func)
{...
        if (join-＞having || select_lex-＞with_sum_func ||
                select_lex-＞group_list.elements) /* 如果有HAVING子句、聚集函数或者GROUPBY子句存在,则确认是否存在NULL IN (SELECT ...)的情况 */
        {
                        bool tmp;
                        Item *item= func-＞create(expr, new Item_ref_null_helper(&select_lex-＞context,
                                this, select_lex-＞ref_pointer_array,
                                (char *)”＜ref＞”,this-＞full_name()));
                        if (!abort_on_null && left_expr-＞maybe_null)
                        {
                                /* 因left_expr-＞maybe_null为真,意味着需要处理NULL IN (SELECT ...)的情况,处理方式是在子查询中增加trig_cond条件(实则是优化过程中把需要判断的条件“打包”在一起,置于子查询的条件判断处一起处理),所以,首先生成将被添加到子查询的条件子句的内容item,然后调用and_items函数完成添加 */
                                item= new Item_func_trig_cond(item, get_cond_guard(0));
                        }
                select_lex-＞having= join-＞having= and_items(join-＞having, item); /* 加入子查询的HAVING子句上,在后续JOIN.optimize()函数中,可以被作为条件部分完成条件的优化 */
...
        }
        else //处理没有HAVING子句、聚集函数或者GROUPBY子句的情况
        {...
                if (select_lex-＞table_list.elements)//如果有FROM子句
                {...
                        if (!abort_on_null && orig_item-＞maybe_null)
                        {...
                                if (left_expr-＞maybe_null)//如果初始表达式值可能为NULL且左操作符值可能为NULL
                                {
                                        if (!(having= new Item_func_trig_cond(having, get_cond_guard(0))))
                                                DBUG_RETURN(RES_ERROR);
                                }
...
                        }
                        if (!abort_on_null && left_expr-＞maybe_null) /* 类似上面相似代码(if条件相同的代码)的处理。以下的代码处理都类似上面的代码,只是判断条件和处理的对象不尽相同,但处理的原因和逻辑都相似 */
                        {
                                if (!(item= new Item_func_trig_cond(item, get_cond_guard(0))))
                                        DBUG_RETURN(RES_ERROR);
                        }
...
                }
                else
                {...
                        if (select_lex-＞master_unit()-＞first_select()-＞next_select())
                        {
                                Item *new_having= func-＞create(expr,
                                         new Item_ref_null_helper(&select_lex-＞context, this,
                                         select_lex-＞ref_pointer_array,
                                         (char *)”＜no matter＞”,
                                         (char *)”＜result＞”));
                                if (!abort_on_null && left_expr-＞maybe_null)
                                {
                                        if (!(new_having= new Item_func_trig_cond(new_having, get_cond_guard(0))))
                                                DBUG_RETURN(RES_ERROR);
                                }
...
                        }
                        else
                        {...item= func-＞create(left_expr, item);...}//没有FROM子句的简单查询处理
                }
        }
...
}


```