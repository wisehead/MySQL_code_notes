#1.make_join_select

```cpp
/*
13.2.6 make_join_select——对条件求值、下推连接条件到表中

make_join_select函数用于分解连接条件（WHERE、ON子句中的条件），下推选择等条件到表中。

需要注意的是，make_join_select函数通过调用add_not_null_conds函数为列对象增加非空条件，进而利用语义优化技术进行优化。

make_join_select函数的实现代码如下：
*/
static bool make_join_select(JOIN *join,SQL_SELECT *select,COND *cond)
{...
        {
                //优化点:重要操作。把列上的非NULL语义加入到条件中,有利于条件判断(语义优化的技术使用)
                add_not_null_conds(join);
                /* 步骤一：抽取表达式中的常量。调用的函数包括：make_cond_for_table/and_conditions/Item_func_trig_cond
                        1) WHERE子句中的常量在抽取的过程中即进行计算,如果有条件不满足,得到空结果集
                        2) ON子句中的常量在抽取的过程中需要封装到Item_func_trig_cond
                */
                if (cond)        /* Because of QUICK_GROUP_MIN_MAX_SELECT */
                {...}
        }//第一个步骤结束
...
        //第二个步骤,遍历每个表,对于可能的条件进行下推
        for (uint i=join-＞const_tables ; i ＜ join-＞tables ; i++)
        {...
                if (pushdown_on_conditions(join, tab))
                        DBUG_RETURN(1);
        }//第二个步骤结束
        DBUG_RETURN(0);
}

```

#2.caller

```
❏make_join_select调用make_cond_for_table函数，把条件和表对应，以便于下推。

❏make_join_select函数调用pushdown_on_conditions，把条件下推。

❏make_join_select函数被JOIN.optimize方法调用。
```