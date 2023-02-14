#0.code

```
propagate_cond_constants
--if (cond->type() == Item::COND_ITEM)
--else if (and_father != cond && !cond->marker)// In a AND group
----
```

#1.propagate_cond_constants

```cpp
/*
propagate_cond_constants函数通过反复递归，完成对每一层的条件表达式的分解和处理。对于条件表达式中的每一项，通过调用resolve_const_item函数完成常量的求值，并通过调用change_cond_ref_to_const函数完成field=field到field=const的化简。propagate_cond_constants函数的实现代码如下：
*/

static void
propagate_cond_constants(THD *thd, I_List＜COND_CMP＞ *save_list,
                                                        Item *and_father, Item *cond)
{
        if (cond-＞type() == Item::COND_ITEM)
        {
...
                while ((item=li++)) //递归调用propagate_cond_constants
                {
                        propagate_cond_constants(thd, &save,and_level ? cond : item, item);
                }
                if (and_level)
                {         // Handle other found items
...
                        while ((cond_cmp=cond_itr++))
                        {
                                Item **args= cond_cmp-＞cmp_func-＞arguments();
                                if (!args[0]-＞const_item()) //完成field = field到field = const的化简
                                        change_cond_ref_to_const(thd, &save,cond_cmp-＞and_level,
                                                cond_cmp-＞and_level, args[0], args[1]);
                        }
                }
        }
        else if (and_father != cond && !cond-＞marker) // In a AND group
        {
                if (cond-＞type() == Item::FUNC_ITEM &&
                        (((Item_func*) cond)-＞functype() == Item_func::EQ_FUNC ||
                         ((Item_func*) cond)-＞functype() == Item_func::EQUAL_FUNC))
                {...
                        if (!(left_const && right_const) &&
                                 args[0]-＞result_type() == args[1]-＞result_type())
                                 {
                                 if (right_const)/* 已经求知表达式含有常数,故调用resolve_const_item求解常数表达式,然后调用change_cond_ref_to_const用刚求解得到的常量值(args[1])把表达式的格式变为类似field = const的样式 */
                                 {
                           resolve_const_item(thd, &args[1], args[0]);
                           func-＞update_used_tables();
                           change_cond_ref_to_const(thd, save_list, and_father, and_father,
                                         args[0], args[1]);
                                 }
                                 else if (left_const)//处理同上,注意求解得到的常量值不是args[1]而是args[0]
                                {
                                        resolve_const_item(thd, &args[0], args[1]);
                                        func-＞update_used_tables();
                                        change_cond_ref_to_const(thd, save_list, and_father, and_father,
                                                                          args[1], args[0]);
                                }
                        } // if (right_const)结束
                }
        } // else if (and_father != cond && !cond-＞marker)结束
}

```

#2.caller

```cpp
❏resolve_const_item函数用于消除表达式中的常量。

❏change_cond_ref_to_const函数用于进行field=field到field=const的变换。

❏resolve_const_item函数、change_cond_ref_to_const函数被propagate_cond_constants函数调用多次。

❏propagate_cond_constants函数被优化条件表达式的optimize_cond函数调用，完成条件表达式中与常量相关的优化。
```