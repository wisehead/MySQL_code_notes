#1.optimize_semijoin_nests_for_materialization

```cpp
/*
5.optimize_semijoin_nests_for_materialization，使用“物化”优化半连接
optimize_semijoin_nests_for_materialization函数实现的功能是，如果可以使用“物化”操作优化SQL语句中的半连接操作，则用“物化”优化半连接操作。

optimize_semijoin_nests_for_materialization函数的实现代码如下：
*/

static bool optimize_semijoin_nests_for_materialization(JOIN *join)
{...
        while ((sj_nest= sj_list_it++))//遍历半连接的表
        {...
                //如果允许使用“物化”,计算物化的花费
                if (join-＞thd-＞optimizer_switch_flag(OPTIMIZER_SWITCH_SEMIJOIN) &&
                        join-＞thd-＞optimizer_switch_flag(OPTIMIZER_SWITCH_MATERIALIZATION))
                {...
                        /* Check whether data types allow execution with materialization. */
                        semijoin_types_allow_materialization(sj_nest);
                        if (!sj_nest-＞nested_join-＞sjm.scan_allowed && !sj_nest-＞nested_join-＞sjm.lookup_allowed)
                                continue;
                        /* 求解半连接相关表的最优连接路径(将求得一个局部连接的最优路径,因为半连接操作可能只是一个查询的一部分) */
                        if (Optimize_table_order(join-＞thd, join, sj_nest).choose_table_order())
                                DBUG_RETURN(true);
...
                        //计算物化的花费
                        calculate_materialization_costs(join, sj_nest, n_tables, &sj_nest-＞nested_join-＞sjm);
...
                }
        }
        DBUG_RETURN(false);
}
```

#2.caller

```cpp
❏optimize_semijoin_nests_for_materialization函数被make_join_statistics函数调用，用物化优化半连接操作。

❏optimize_semijoin_nests_for_materialization函数通过调用semijoin_types_allow_materialization函数进而调用types_allow_materialization函数，完成对于半连接是否可以物化的判断。

❏optimize_semijoin_nests_for_materialization函数被subquery_allows_materialization函数调用，最后被make_join_statistics函数调用，用以处理子查询，处理子查询的过程类似处理查询的过程。
```