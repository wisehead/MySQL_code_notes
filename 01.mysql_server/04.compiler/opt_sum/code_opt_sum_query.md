#1.opt_sum_query

```
JOIN::optimize
--opt_sum_query
```

#2.code flow

```cpp
/*
opt_sum_query函数用于对查询语句中带有聚集函数（包括COUNT()、MIN()、MAX()）、且没有GROUPBY子句的形式进行优化（所谓优化，就是对COUNT函数利用储存引擎的功能直接求值，对MIN/MAX函数利用索引直接求值）。使用opt_sum_query函数进行优化时分为如下情况。

❏COUNT函数：没有WHERE子句、函数参数不可为NULL、不存在外连接、能够精确计数，则调用get_exact_record_count函数为COUNT函数的求精确值。

❏MIN/MAX函数：调用find_key_for_maxmin查看是否可以利用索引得到MAX/MIN的值，如果能利用，则会大大加快执行速度。
*/

int
opt_sum_query (THD *thd, TABLE_LIST *tables, List＜Item＞ &all_fields, Item *conds)
{
        List_iterator_fast＜Item＞ it(all_fields);
...
        //统计所有叶子结点上的单表,如果作笛卡儿集,其最大的连接后的行数
        /* 入口参数tables的输入是select_lex-＞leaf_tables,查询语句中的所有的单表对象,都存于叶子结点select_lex-＞leaf_tables */
        /* 尽管带有MAX函数且没有GROUPBY子句,但不支持的优化形式如下(带有外连接但WHERE子句的条件限制了内表) */
        //  SELECT MAX(t1.a) FROM t1 LEFT JOIN t2 join-condition
        //                WHERE t2.field IS NULL;
        for (TABLE_LIST *tl= tables; tl; tl= tl-＞next_leaf){...} /* 尽量利用储存引擎的功能(有的储存引擎提供直接对表的行数计数的功能,所以不需要额外计算,直接获取即可)完成求多表连接后笛卡儿集的行数计算 */
        //遍历传入的每个列对象，如果列上存在COUNT/MIN/MAX函数，则尽可能优化
        while ((item= it++))
        {
                if (item-＞type() == Item::SUM_FUNC_ITEM)//如果是聚集函数则进行优化
                {
                        Item_sum *item_sum= (((Item_sum*) item));
                        switch (item_sum-＞sum_func()) {
                                case Item_sum::COUNT_FUNC://聚集函数中的COUNT函数
                                        /* 没有WHERE子句、函数参数不可为NULL、不存在外连接、能够精确计数,则调用get_exact_record_count函数求精确值 */
                                        if (!conds && !((Item_sum_count*) item)-＞get_arg(0)-＞maybe_null &&
                                                !outer_tables && maybe_exact_count)
                                        {
                                                if (!is_exact_count)
                                                {
                                                        if ((count= get_exact_record_count(tables)) == ULONGLONG_MAX)...
                                                }
                                        }
                                        else if (...) //如果是全文检索需要计数,求COUNT值
                                        {...
                                                count= fts_item-＞get_count();
                                        }
                                        else
                                                const_result= 0;
                                        break;
                                case Item_sum::MIN_FUNC: //聚集函数中的MIN函数
                                case Item_sum::MAX_FUNC: //聚集函数中的MAX函数
                                {...
                                        int is_max= test(item_sum-＞sum_func() == Item_sum::MAX_FUNC);
                                        Item *expr=item_sum-＞get_arg(0);
                                        if (expr-＞real_item()-＞type() == Item::FIELD_ITEM)
                                        {...
                                                /* 调用find_key_for_maxmin查看是否可以利用索引得到MAX/MIN的值,如果能利用索引,则会大大加快执行速度 */
                                                if (table-＞file-＞inited || (outer_tables & table-＞map) ||
                                                                   !find_key_for_maxmin(is_max, &ref, item_field-＞field, conds,
                                                                   &range_fl, &prefix_len))
                                                {
                                                        const_result= 0;
                                                        break;
                                                }
...
                                                /* 如果是MAX则调用get_index_max_value获得最大值;否则调用get_index_min_value获得最小值。注意,此阶段求得最值的真实值,有利于后续利用常量进行其他技术的优化 */
                                                error= is_max ?
                                                        get_index_max_value(table, &ref, range_fl) :
                                                        get_index_min_value(table, &ref, item_field, range_fl, prefix_len);
...
                                        } // if (expr-＞real_item()-＞type() == Item::FIELD_ITEM)结束
                                        else if (!expr-＞const_item() || conds || !is_exact_count)
                                        {
                                                //MIN/MAX函数不是基于列对象,如SELECT MAX(1) FROM table ...
                                                const_result= 0;
                                                break;
                                        }
...
                                        break;
                                }
                        default:
                                const_result= 0;
                                break;
                        }
                }
                else ...
        }//while语句结束
...
}
```

#3.comments

```cpp
/**
  Substitutes constants for some COUNT(), MIN() and MAX() functions.

  @param thd                   thread handler
  @param tables                list of leaves of join table tree
  @param all_fields            All fields to be returned
  @param conds                 WHERE clause

  @note
    This function is only called for queries with aggregate functions and no
    GROUP BY part. This means that the result set shall contain a single
    row only

  @retval
    0                    no errors
  @retval
    1                    if all items were resolved
  @retval
    HA_ERR_KEY_NOT_FOUND on impossible conditions
  @retval
    HA_ERR_... if a deadlock or a lock wait timeout happens, for example
  @retval
    ER_...     e.g. ER_SUBQUERY_NO_1_ROW
*/
```