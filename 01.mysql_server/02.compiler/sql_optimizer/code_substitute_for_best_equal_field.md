#1.substitute_for_best_equal_field

```cpp
/*
4.substitute_for_best_equal_field，去除冗余等式

substitute_for_best_equal_field函数通过递归调用自己，完成条件表达式的逐层分解；通过调用eliminate_item_equal函数，去除条件表达式中发现的冗余等式。substitute_for_best_equal_field函数只能对条件表达式和多重相等函数的条件表达式进行处理。

substitute_for_best_equal_field函数的实现代码如下：
*/
static COND* substitute_for_best_equal_field(COND *cond, //被处理的条件
                                                                                          COND_EQUAL *cond_equal, //cond中的子式
                                                                                          void *table_join_idx) //指定表在连接树中的位置
{...
        if (cond-＞type() == Item::COND_ITEM)//对表达式进行处理
        {...
                /* MySQL特点：如果条件是析取范式,则遍历其中的每个子式,按表的连接次序对条件表达式中的每个等式排序(在这之前多表连接算法被执行,表已经有序),好处是在访问表时尽量提前对表的条件进行计算 */
                bool and_level= ((Item_cond*) cond)-＞functype() == Item_func::COND_AND_FUNC;
                if (and_level)
                {
                        cond_equal= &((Item_cond_and *) cond)-＞cond_equal;
                        cond_list-＞disjoin((List＜Item＞ *) &cond_equal-＞current_level);
                        List_iterator_fast＜Item_equal＞ it(cond_equal-＞current_level);
                        while ((item_equal= it++)) //遍历其中的每个子式,排序
                        { item_equal-＞sort(&compare_fields_by_table_order, table_join_idx); }
                }
...
                while ((item= li++)) //递归遍历条件中的所有内容
                {
                        Item *new_item =substitute_for_best_equal_field(item, cond_equal, table_join_idx);
                ...
                }
                if (and_level)
                {
                        List_iterator_fast＜Item_equal＞ it(cond_equal-＞current_level);
                        while ((item_equal= it++)) //遍历条件中的每个子式,消除冗余
                        {
                                cond= eliminate_item_equal(cond, cond_equal-＞upper_levels, item_equal);
...                     }
                }
                if (cond-＞type() == Item::COND_ITEM &&
                        !((Item_cond*)cond)-＞argument_list()-＞elements)
                        cond= new Item_int((int32)cond-＞val_bool()); //条件化简：可求值的布尔条件
        }
        //对多重相等函数的条件表达式,一是按表排序,二是消除冗余
        else if (cond-＞type() == Item::FUNC_ITEM &&
                ((Item_cond*) cond)-＞functype() == Item_func::MULT_EQUAL_FUNC)
        {
                item_equal= (Item_equal *) cond;
                item_equal-＞sort(&compare_fields_by_table_order, table_join_idx);
                if (cond_equal && cond_equal-＞current_level.head() == item_equal)
                      ?cond_equal= cond_equal-＞upper_levels;
                      ?return eliminate_item_equal(0, cond_equal, item_equal);
        }
        else
                cond-＞transform(&Item::replace_equal_field, 0);
        return cond;
}

```

#2.caller

```
❏eliminate_item_equal函数被substitute_for_best_equal_field函数调用，用于去除冗余的等式。

❏substitute_for_best_equal_field被自己和JOIN.optimize调用，找到所有的条件表达式然后去除冗余等式。
```