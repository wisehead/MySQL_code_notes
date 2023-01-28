#1.Optimize_table_order::consider_plan

```cpp
/*
（2）consider_plan，考虑新生成的查询计划是否是最优的

consider_plan函数用于计算idx指定的新的查询执行计划的花费，如果新的花费比历史上最好的花费还小，则保存新的花费对应的路径到join-＞best_positions。

consider_plan函数的实现代码如下：
*/
void Optimize_table_order::consider_plan(uint                idx,
                                                                                  double        record_count,
                                                                                  double        read_time,
                                                                                  Opt_trace_object *trace_obj)
{
        /* 启发式规则：如果有排序操作且排序表不是连接中的第一个表(常量表不计算在内),考虑把排序操作的花费加在总花费中。如果排序表是连接中的第一个表,排序操纵可被消除,所以不用计算排序的花费 */
        if (join-＞sort_by_table &&
                 join-＞sort_by_table !=
                 join-＞positions[join-＞const_tables].table-＞table)
        {   read_time+= record_count; ...  }
        //新的花费比历史上最好的花费还小,则保存新的花费到join-＞best_positions
        const bool chosen= read_time ＜ join-＞best_read;
        trace_obj-＞add("chosen", chosen);
        if (chosen)
        {
                memcpy((uchar*) join-＞best_positions, (uchar*) join-＞positions,
                          sizeof(POSITION) * (idx + 1));
...
                join-＞best_read= read_time - 0.001;
                join-＞best_rowcount= (ha_rows)record_count;
        }
...
}
```

#2.caller

```
consider_plan函数被best_extension_by_limited_search、eq_ref_extension_by_limited_search函数调用，完成这两个函数生成的最终最优查询执行计划花费的估算。
```