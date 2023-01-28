#1.remove_eq_conds

```cpp
/*
remove_eq_conds函数用于去除等式中的无用条件，即消除“死码”（dead code）。
*/
Item *
remove_eq_conds(THD *thd, Item *cond, Item::cond_result *cond_value)
{
        if (cond-＞type() == Item::FUNC_ITEM && ((Item_func*) cond)-＞functype() == Item_func::ISNULL_FUNC)
        {...}//为ODBC做特例处理
        return internal_remove_eq_conds(thd, cond, cond_value); // Scan all the condition
}
static Item *
internal_remove_eq_conds(THD *thd, Item *cond, Item::cond_result *cond_value)
{
        if (cond-＞type() == Item::COND_ITEM)
        {...
                while ((item=li++))
                {
                        Item *new_item=internal_remove_eq_conds(thd, item, &tmp_cond_value); /*递归处理各项中的子表达式 */
                        /* 开始做各种处理,如
                        1) 条件值总是true：where 2＞1 and col=8将变为where col=8,等式中、无用的条件2＞1因为总是true被remove了
                        2) 条件值总是false：where 2＜1 and col=8 or col=6将变为where col=6,等式中、无用的条件2＜1 and col=8因为总是false被remove了
                        3) 如果一个列值不可能为NULL,则在以下两种情况下,也会被优化而去掉
                              3.1 where not_null_col  IS  NULL                 条件表达式总是值为false
                              3.2 where not_null_col  IS  NOT  NULL       条件表达式总是值为true */
...
                   }
...
        }
        else if (cond-＞type() == Item::FUNC_ITEM &&
                          ((Item_func*) cond)-＞functype() == Item_func::ISNULL_FUNC)
        {...}
...
}

```

#2.caller

```cpp
❏remove_eq_conds被JOIN.optinize、optimize_cond、mysql_update三个函数调用，用于完成DML和DQL语句中常量表达式的死码去除的优化。

❏remove_eq_conds函数调用internal_remove_eq_conds函数完成去除死码的主要功能。

```