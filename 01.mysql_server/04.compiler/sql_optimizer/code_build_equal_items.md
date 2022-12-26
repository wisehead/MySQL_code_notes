#1.build_equal_items

```cpp
/*
build_equal_items函数用于过滤所有的条件表达式，调用build_equal_items_for_cond函数完成对条件表达式中相等项的合并。如(t1.a=t2.b AND t2.b＞5AND t1.a=t3.c)被合并为(=(t1.a，t2.b，t3.c)AND t2.b＞5)。

build_equal_items的实现代码如下：
*/
Item *build_equal_items(THD *thd, Item *cond, COND_EQUAL *inherited,
                                        bool do_inherit, List＜TABLE_LIST＞ *join_list,
                                        COND_EQUAL **cond_equal_ref)
{...
        if (cond) //调用build_equal_items_for_cond函数完成对条件表达式中相等项的合并
        {        cond= build_equal_items_for_cond(thd, cond, inherited);...  }
...
                if (join_list)
                {...
                        while ((table= li++))//遍历join_list上存在的表对象上的条件表达式on_expr
                        {
                                if (table-＞join_cond()) //如果表上存在连接条件，递归处理条件子句
                                {
                                        List＜TABLE_LIST＞ *nested_join_list= table-＞nested_join ?
                                                &table-＞nested_join-＞join_list : NULL;
...
                                        table-＞set_join_cond(build_equal_items(thd, table-＞join_cond(), //递归调用自己
                                                inherited, do_inherit, nested_join_list, &table-＞cond_equal));
                                }
                        }// while ((table= li++))遍历join_list结束
                }// if (join_list)结束
...
        }
}

```

#2.caller

```cpp
总的调用关系为optimize_cond→build_equal_items→build_equal_items_for_cond→check_equality。

```