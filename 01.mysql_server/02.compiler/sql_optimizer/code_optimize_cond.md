#1.optimize_cond

```
JOIN::optimize
--optimize_cond
```

#2.code flow

```cpp
/*
optimize_cond函数用于条件表达式优化，其应用多等式谓词的传递特性
（即等式传递，multiple equality predicates，MEP）优化条件表达式，
主要的优化对象是WHERE、JOIN/ON、HAVING中的条件表达式。

optimize_cond函数优化针对以下3种情况进行。
❏等式合并：找出相等的条件合并在一起，去除重复的条件，
如SELECT*FROM(t1，t2)LEFT JOIN(t3，t4)ON t1.a=t3.a AND t2.a=t4.a WHERE t1.a=t2.a;
将得到COND类型的格式如=(t1.a，t2.a，t3.a，t4.a)这样的相等条件，即t1.a、t2.a出现多次，
则去掉重复的。

❏常量求值：把形如field=field格式可求解表达式的、转换为field=const格式，
便于优化器优化（可方便优化器对于转换后的表达式判断如何利用索引）。
如3=t.a转换为t.a=3；t.a=3+2求解为t.a=5，对t.a就可以尽量使用索引。

❏条件去除：去掉不可能的条件表达式或者值为TRUE的条件。如1=3的条件被替换为FALSE；
1=1的条件被替换为TRUE；1=3AND t1.a=t2.a，则因1=3被认为FALSE后，
AND的整个条件就可以认为是FALSE。
*/

Item *
optimize_cond(THD *thd, Item *conds, COND_EQUAL **cond_equal,
                                 List＜TABLE_LIST＞ *join_list,
                                 bool build_equalities, Item::cond_result *cond_value)
{...
        if (conds)
        {
                //优化一：等式合并
                if (build_equalities)
                {...
                        {...
                                conds= build_equal_items(thd, conds, NULL, true, join_list, cond_equal);
                        }...
                }
...
                //优化二：常量求值
                propagate_cond_constants(thd, (I_List＜COND_CMP＞ *) 0, conds, conds);
...
                //优化三：条件去除。去掉带有常量的表达式,这样能简化条件
                conds= remove_eq_conds(thd, conds, cond_value) ;
...
        }
        DBUG_RETURN(conds);
}
```

#3.comments

```cpp
/**
  Optimize conditions by 

     a) applying transitivity to build multiple equality predicates
        (MEP): if x=y and y=z the MEP x=y=z is built. 
     b) apply constants where possible. If the value of x is known to be
        42, x is replaced with a constant of value 42. By transitivity, this
        also applies to MEPs, so the MEP in a) will become 42=x=y=z.
     c) remove conditions that are impossible or always true
  
  @param      join         pointer to the structure providing all context info
                           for the query
  @param      conds        conditions to optimize
  @param      join_list    list of join tables to which the condition
                           refers to
  @param[out] cond_value   Not changed if conds was empty 
                           COND_TRUE if conds is always true
                           COND_FALSE if conds is impossible
                           COND_OK otherwise

  @return optimized conditions
*/
```