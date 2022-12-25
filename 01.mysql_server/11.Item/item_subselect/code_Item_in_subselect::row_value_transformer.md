#1.Item_in_subselect::row_value_transformer

```cpp
Item_subselect::trans_res
Item_in_subselect::row_value_transformer(JOIN *join)
{...
        DBUG_RETURN(row_value_in_to_exists_transformer(join)); /* IN操作向EXISTS半连接转换,调用row_value_in_to_exists_transformer函数完成 */
}
Item_subselect::trans_res
Item_in_subselect::row_value_in_to_exists_transformer(JOIN * join)
{...
        bool is_having_used= (join-＞having || select_lex-＞with_sum_func ||
                                select_lex-＞group_list.first || !select_lex-＞table_list.elements);
...
        if (is_having_used) //存在HAVING子句或聚集函数或分组子句等
        {
                /*
                        被优化的子查询格式为：
                        (l1, l2, l3) IN (SELECT v1, v2, v3 ... HAVING having)
                        可优化为
                        EXISTS (SELECT ... HAVING having and
                                (l1 = v1 or is null v1) and
                                (l2 = v2 or is null v2) and
                                (l3 = v3 or is null v3) and
                                is_not_null_test(v1) and
                                is_not_null_test(v2) and
                                is_not_null_test(v3))
                */
                Item *item_having_part2= 0;
                for (uint i= 0; i ＜ cols_num; i++)//循环处理如上表达式中的子查询语句部分的每一列
                {
...
                        Item *item_nnull_test= new Item_is_not_null_test (this,
                                new Item_ref (&select_lex-＞context,
                                                select_lex-＞
                                                ref_pointer_array + i,
                                                (char *)"＜no matter＞",
                                                (char *)"＜list ref＞"));
                if (!abort_on_null && left_expr-＞element_index(i)-＞maybe_null) /* 判断条件与single_value_transformer函数中的相似但不同 */
                {
                        if (!(item_nnull_test= new Item_func_trig_cond (item_nnull_test, get_cond_guard(i))))
                                DBUG_RETURN(RES_ERROR);
                        }
                        item_having_part2= and_items (item_having_part2, item_nnull_test);
                        item_having_part2-＞top_level_item();
                }
                having_item= and_items(having_item, item_having_part2);
                having_item-＞top_level_item();
        }
        else //不存在HAVING子句或聚集函数或分组子句等
        {
                /*
                被优化的子查询格式为：
                (l1, l2, l3) IN (SELECT v1, v2, v3 ... WHERE where)
                可优化为：
                EXISTS (SELECT ... WHERE where and
                        (l1 = v1 or is null v1) and
                        (l2 = v2 or is null v2) and
                        (l3 = v3 or is null v3)
                        HAVING is_not_null_test(v1) and
                        is_not_null_test(v2) and
                        is_not_null_test(v3))
                或优化为：
                EXISTS (SELECT ... WHERE where and
                        (l1 = v1) and
                        (l2 = v2) and
                        (l3 = v3)
                */
...
        }
...
}

```