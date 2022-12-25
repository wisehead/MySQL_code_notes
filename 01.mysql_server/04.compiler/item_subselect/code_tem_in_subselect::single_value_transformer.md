#1.item_in_subselect::single_value_transformer

```cpp
Item_subselect::trans_res
Item_in_subselect::single_value_transformer(JOIN *join, Comp_creator *func)
{...
        /* 第一种情况：对于非SQL顶层的子查询(如果查询有嵌套,则最外层的子句即是最顶层的子句)
                如果子查询中NULL结果可以被忽略,则ALL/ANY single-value的子查询,可重写为MIN/MAX聚集函数表达的子查询,例如：
                SELECT * FROM t1 WHERE b ＞ ANY (SELECT a FROM t2)
                可优化为
                SELECT * FROM t1 WHERE b ＞ (SELECT MAX(a) FROM t2) */
        if (!func-＞eqne_op() && // 存在大于或小于比较操作符
                !select_lex-＞master_unit()-＞uncacheable && // 非相关子查询
                (abort_on_null || (upper_item && upper_item-＞top_level()) ||  /*  UNKNOWN results are treated as FALSE, or can never be generated */
                (!left_expr-＞maybe_null && !subquery_maybe_null)))
        {...
                Item *subs;
                if (!select_lex-＞group_list.elements &&  //没有GROUPBY子句
                        !select_lex-＞having &&  //没有HAVING子句
                        !select_lex-＞with_sum_func &&  //没有聚集函数
                        !(select_lex-＞next_select()) &&
                        select_lex-＞table_list.elements &&
                        !(substype() == ALL_SUBS && subquery_maybe_null)) /* 子查询谓词ALL且结果可能为NULL的类型不能优化 */
                {...
                        if (func-＞l_op()){
                                item= new Item_sum_max(*select_lex-＞ref_pointer_array);/* 如果谓词是＞=ALL、＞ALL、＜=ANY、＜ANY,则可用聚集函数MAX优化,所以,调用Item_sum_max类 */
                        }
                        else{
                                item= new Item_sum_min(*select_lex-＞ref_pointer_array); /* 如果谓词是＜=ALL、＜ALL、＞=ANY、＞ANY等,则可用聚集函数MIN优化,所以,调用Item_sum_min类 */
                        }
...
                        subs= new Item_singlerow_subselect(select_lex); /* 无论是可转为MAX还是转为MIN聚集函数格式,子查询的返回值都是一个单行单列的值;subs代表优化后的子查询 */
                }
                else{...}
                substitution= func-＞create(left_expr, subs); /*  substitution是优化后的子表达式(左操作符和subs联合构成新的子表达式) */
        }
        if (!substitution){...}//上面代码发现子查询没有可优化之处,则做一些处理
...
        /* 执行IN类型子查询向EXISTS类型转换 */
        const trans_res retval= single_value_in_to_exists_transformer(join, func);
...
}// single_value_transformer函数结束
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