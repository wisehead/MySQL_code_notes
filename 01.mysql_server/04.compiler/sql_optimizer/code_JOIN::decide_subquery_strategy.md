#1.JOIN::decide_subquery_strategy

```cpp
/*
1.decide_subquery_strategy，确定子查询的优化策略

decide_subquery_strategy函数用于确定子查询的优化策略。在本函数中，可选的子查询优化策略为EXISTS strategy、materialization二者之一。

decide_subquery_strategy函数的实现代码如下：
*/
bool JOIN::decide_subquery_strategy()
{...
        switch (unit-＞item-＞substype())
        {
               case Item_subselect::IN_SUBS:
               case Item_subselect::ALL_SUBS:
               case Item_subselect::ANY_SUBS:  //只支持以上3种子查询类型,选取子查询优化策略
                      // All of those are children of Item_in_subselect and may use EXISTS
                      break;
               default: //其他类型的子查询不支持选取子查询优化策略
                      return false;
        }
...
        //物化不支持UNION 操作
        DBUG_ASSERT(chosen_method != Item_exists_subselect::EXEC_MATERIALIZATION);
        if ((chosen_method == Item_exists_subselect::EXEC_EXISTS_OR_MAT) &&
               compare_costs_of_subquery_strategies(&chosen_method))
               //计算EXISTS strategy和materialization二者的花费
               return true;
        switch (chosen_method)
        {
               case Item_exists_subselect::EXEC_EXISTS:
                        return in_pred-＞finalize_exists_transform(select_lex); /* 子查询进行EXISTS strategy转换 */
               case Item_exists_subselect::EXEC_MATERIALIZATION:
                        return in_pred-＞finalize_materialization_transform(this); //子查询进行“materialization”转换
               default:
                        DBUG_ASSERT(false);
                        return true;
        }
}

```

#2.caller

```
compare_costs_of_subquery_strategies被decide_subquery_strategy调用，依据代价计算完成对子查询策略的选择。
```