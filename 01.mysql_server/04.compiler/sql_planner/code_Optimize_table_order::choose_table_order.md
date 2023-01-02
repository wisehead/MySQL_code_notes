#1.Optimize_table_order::choose_table_order

```
make_join_statistics
--Optimize_table_order::choose_table_order

other callers:
-optimize_semijoin_nests_for_materialization
-compare_costs_of_subquery_strategies
```

#2.code flow
```cpp
/*
choose_table_order函数选择一个生成多表连接的查询计划的搜索算法，然后求解最优的连接顺序，即连接路径。

在旧版的MySQL源码中，choose_table_order函数的前身是choose_plan函数。曾有以下3种多表连接优化算法。
❏optimize_straight_join：强制优化器使用FROM/JOIN子句中指定的表的连接次序进行多表连接。用法如下：
SELECT /*! STRAIGHT_JOIN */ col_1 FROM table1,table2 WHERE ...;
如果能确定指定连接次序的连接方式可得到最优的查询计划，则完全可以通过指定STRAIGHT_JOIN来节约MySQL对于查询优化的探索时间，进而提高效率。

❏find_best：通过使用穷尽式搜索方法，搜索表之间的各种组合以得到最优的查询计划。

❏greedy_search：通过使用混杂贪婪式和穷尽式搜索方法，搜索表之间的各种组合以得到最优的查询计划。

在MySQL V5.6.X，多表连接优化算法去掉了上述的第二种算法，留下了第一种和第三种算法。

choose_table_order函数的实现代码如下：
*/

bool Optimize_table_order::choose_table_order()
{...
        //全是常量表不用做多表连接的优化
        if (join-＞const_tables == join-＞tables)
        {
                memcpy(join-＞best_positions, join-＞positions, sizeof(POSITION) * join-＞const_tables);
                join-＞best_read= 1.0;
                join-＞best_rowcount= 1;
                DBUG_RETURN(false);
        }
...
        //确定是否采用SQL语句指定的连接次序执行多表连接查询计划的生成
        /* 如果在SQL语句中通过hit指定STRAIGHT_JOIN,则join-＞select_options被赋SELECT_STRAIGHT_JOIN值 */
        const bool straight_join= test(join-＞select_options & SELECT_STRAIGHT_JOIN);
        table_map join_tables;          ///＜ The tables involved in order selection
        if (emb_sjm_nest)//如果存在半连接,通过物化方式优化
        {
                merge_sort(join-＞best_ref + join-＞const_tables,
                          join-＞best_ref + join-＞tables,
                          Join_tab_compare_embedded_first(emb_sjm_nest));
                join_tables= emb_sjm_nest-＞sj_inner_tables;
        }
        else //否则,需要对多表连接进行优化求解最优查询路径
        {
                if (straight_join)//使用用户指定的表连接次序对要连接的表排序,常量表除外
                        merge_sort(join-＞best_ref + join-＞const_tables,
                                 join-＞best_ref + join-＞tables, Join_tab_compare_straight());
                else /* 否则,使用greedy_search算法，但之前需要对要连接的表排序。排序的方式是,按照表的元组数,从小到大排序要连接的表。这是一条启发规则：MySQL认为按照可访问到的元组个数从小到大为所有基表排序可获得更好的多表连接路径 */
                        merge_sort(join-＞best_ref + join-＞const_tables,
                                 join-＞best_ref + join-＞tables, Join_tab_compare_default());
                //所有的基表去掉常量表就是用于连接的表
                join_tables= join-＞all_table_map & ~join-＞const_table_map;
        } //else结束
...
        if (straight_join) //使用用户指定的表连接次序进行连接,查询优化器不再进行优化
                optimize_straight_join(join_tables); /* 多表连接方法一：强制优化器使用SQL语句中指定的表的连接次序进行多表连接 */
        else //否则,调用greedy_search函数对多表连接进行优化
        {
                if (greedy_search(join_tables)) //多表连接方法二：贪婪算法
                        DBUG_RETURN(true);
        }
...
        if (fix_semijoin_strategies())  //修改半连接策略并估算花费
                DBUG_RETURN(true);
        DBUG_RETURN(false);
}

```

#3.caller

```
❏choose_table_order方法被make_join_statistics函数调用，以解决多表连接顺序的问题。

❏choose_table_order方法被其他函数调用，解决查询语句子句的局部多表连接优化问题，如子查询、半连接等。
```

#4.comments

```cpp
/**
  Selects and invokes a search strategy for an optimal query join order.

  The function checks user-configurable parameters that control the search
  strategy for an optimal plan, selects the search method and then invokes
  it. Each specific optimization procedure stores the final optimal plan in
  the array 'join->best_positions', and the cost of the plan in
  'join->best_read'.
  The function can be invoked to produce a plan for all tables in the query
  (in this case, the const tables are usually filtered out), or it can be
  invoked to produce a plan for a materialization of a semijoin nest.
  Set a non-NULL emb_sjm_nest pointer when producing a plan for a semijoin
  nest to be materialized and a NULL pointer when producing a full query plan.

  @return false if successful, true if error
*/
```