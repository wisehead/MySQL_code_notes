#1.Optimize_table_order::optimize_straight_join

```cpp
/*
optimize_straight_join函数用于按指定的表的次序（循环条件中表示不同表位置的值递增）求解单表s访问信息（表的扫描方式、花费等，其他信息参见POSITION结构体）。当单表的访问信息得到后，即得到最终的查询计划，这是因为表的连接次序已经指定，不需要考虑表的次序不同导致花费不同的问题（但这正是多表连接优化的意义所在）。这种方式，适用于SQL语句本身就是最优的情况，不再需要MySQL的查询优化器对SQL进行优化。

optimize_straight_join函数的实现代码如下：
*/
void Optimize_table_order::optimize_straight_join(table_map join_tables)
{...
        uint idx= join-＞const_tables; //得到常量表的个数
...
        /* join-＞best_ref  ＋ idx表示从常量表之后的表开始的连接语义中的其他表,为每个表求最优路径(常量表不用考虑是因为表的被访问的元组数固定且和其他表元组做连接也确定) */
        for (JOIN_TAB **pos= join-＞best_ref + idx ; (s= *pos) ; pos++)
        {
                POSITION * const position= join-＞positions + idx; //idx自增,position指向的位置后移
...
                //计算表s的访问方式、花费等,结果保存在position
                best_access_path(s, join_tables, idx, false, record_count, position, &loose_scan_pos);
                //计算查询计划的花费(每次循环得到的单表的值累计)
                record_count*=        position-＞records_read;
                read_time+=        position-＞read_time;
                read_time+=        record_count * ROW_EVALUATE_COST;
                /* 得到累计的值(如read_time),保存到position中,下次循环时,再累计下个表的read_time值;这样,每次循环,都能把历史read_time累计和保存到当前的position中;所以,最后一个position保存的是所有表时间花费的结果;所以,最后一个能代表最优(join-＞best_positions) */
                position-＞set_prefix_costs(read_time, record_count);
                //如果存在半连接,则优化半连接
                if (!join-＞select_lex-＞sj_nests.is_empty())
                        advance_sj_state(join_tables, s, idx, &record_count, &read_time, &loose_scan_pos);
                else
                        position-＞no_semijoin();
...
                ++idx;//确保下次调用best_access_path函数时,从本次循环使用的表s的下一个表的位置正确
        }
...
        //最后一个代表的是最优的路径
        memcpy(join-＞best_positions, join-＞positions, sizeof(POSITION)*idx);
...
}

```

#2.caller

```
optimize_straight_join方法被choose_table_order方法唯一调用。
```