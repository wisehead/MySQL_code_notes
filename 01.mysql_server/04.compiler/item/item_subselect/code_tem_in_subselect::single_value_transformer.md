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

```