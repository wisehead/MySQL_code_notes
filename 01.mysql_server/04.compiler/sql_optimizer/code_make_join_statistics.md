#1.make_join_statistics

```
JOIN::optimize
--make_join_statistics
```

#2 code flow
```cpp
/*
make_join_statistics函数可为表的连接做准备（求表的依赖关系、计算表的元组数、计算表的数据获取时间），计算最优的查询优化计划（提供两种多表连接优化算法）。其工作的主要过程如下：

1）初始化JOIN的数据结构，建立表之间的依赖关系。
2）基于连接信息更新依赖关系。
3）获取索引信息。
4）基于表的依赖关系选出半连接的表。
5）选出的常量表（包括只有0行或一行数据，也包括因依赖关系导致一些表在连接关系的作用下也可以认为是常量表的表），并获取真实数据。
6）为非常量表计算行数。
7）计算潜在的半连接物化操作的花费。
8）基于统计信息求解最好的连接顺序的花费。
*/

static bool
make_join_statistics(JOIN *join, TABLE_LIST *tables_arg, Item *conds,
                                         Key_use_array *keyuse_array, bool first_optimization)
{...
        //初始化要连接的表的数据结构,并求解表之间的依赖关系
        /* 可用于连接的表放到join-＞best_ref中,所有的叶子结点(基本表)被置于join-＞best_ref数组 */
        for (s= stat, i= 0; tables; s++, tables= tables-＞next_leaf, i++)  {...}
...
        /* 基于连接信息更新依赖关系。如果存在外连接,分为两步处理(两个循环体)：
         1) 使用Warshall算法,构建“表”的“被依赖关系”的传递闭包;这有助于加快含有外连接的多种情况的搜索,便于快速淘汰不合法关系的连接引用。依赖关系被保存在JOIN_TAB的dependent成员上
         2)使用上步构造的传递闭包,检查外连接中不合法的连接 */
        if (join-＞outer_join)  {...}
...
        if (conds || outer_join)//调用update_ref_and_keys函数,获取key(索引)的信息
                if (update_ref_and_keys(thd, keyuse_array, stat, join-＞tables,
                       conds, join-＞cond_equal,
                       ~outer_join, join-＞select_lex, &sargables))
                        goto error;
        /* 基于表间的依赖关系(SQL语句表明的语法上表之间的连接顺序上的依赖),可以把一些用半连接计算的表拉到上层,避开用半连接计算(注意有可能更改语义,使得不相关子查询变成相关子查询,这样,使得本可能利用“物化”或“松散索引扫描”变为不能使用)*/
        if (first_optimization)
        {
                if (pull_out_semijoin_tables(join))
                        DBUG_RETURN(true);
        }
...
        /* 找出JT_SYSTEM、JT_CONST类的表,目的是作多表连接时,几乎可以不考虑这两类的表对连接构成的影响。
           此处代码量较大,有多个独立的循环,一并省略,但都主要调用了set_position函数,例如：
           for (i= 0, s= stat; i ＜ table_count; i++, s++)...
           do{...} while (join-＞const_table_map & found_ref && ref_changed);
        */
        {...set_position();...} /* 注意多次调用了set_position函数,每加入一个新的常量表,把旧的常量表尽量往join-＞best_ref的后面放 */
...
        //验证常量表的元组数,如果常量表的元组个数大于1,报错
        for (POSITION *p_pos=join-＞positions, *p_end=p_pos+const_count;
                 p_pos ＜ p_end ;
                 p_pos++)
        {...if ((tmp=join_read_const_table(s, p_pos)))...}
        //计算每个表元组数
        {...
                for (s= stat ; s ＜ stat_end ; s++)
                {...
                        //如果是常量表(JT_SYSTEM、JT_CONST),元组数至多是1
                        if (s-＞type == JT_SYSTEM || s-＞type == JT_CONST)
                        {...
                                s-＞found_records= s-＞records= s-＞read_time=1; s-＞worst_seeks= 1.0;
                                continue;
                        }
                        //计算非常量表的元组数、获取数据的时间花费、最坏搜索因子
                        s-＞found_records= s-＞records= s-＞table-＞file-＞stats.records;
                        s-＞read_time= (ha_rows) s-＞table-＞file-＞scan_time();
                        s-＞worst_seeks= min((double) s-＞found_records / 10, (double) s-＞read_time * 3);
                        if (s-＞worst_seeks ＜ 2.0)   // Fix for small tables
                                s-＞worst_seeks= 2.0;
                        //如果有GROUPBY、DISTINCT子句,则为这些操作所在的列确定是否有索引可用
                        add_group_and_distinct_keys(join, s);
                        /*
                          Perform range analysis if there are keys it could use (1).
                          Don't do range analysis if on the inner side of an outer join (2).
                          Do range analysis if on the inner side of a semi-join (3).
                        */
                        //如果可以执行范围扫描,则重新计算元组数、获取数据的时间花费;否则,执行全表扫描
                        TABLE_LIST *const tl= s-＞table-＞pos_in_table_list;
                        if (!s-＞const_keys.is_clear_all() &&        // (1)
                                (!tl-＞embedding ||                                          // (2)
                                (tl-＞embedding && tl-＞embedding-＞sj_on_expr))) // (3)
                        {...
                                records= get_quick_record_count(thd, select, s-＞table,
                                        &s-＞const_keys, join-＞row_limit);
...
                        }
                        else//否则,执行全表扫描
                                Opt_trace_object(trace, “table_scan”).
                                          add(“rows”, s-＞found_records). add(“cost”, s-＞read_time);
                } // for (s= stat ; s ＜ stat_end ; s++)结束
        } //计算每个表元组数结束
...
        //为利用好索引,对索引对象Key_use上的值进行更新
        if (!join-＞plan_is_const())
                optimize_keyuse(join, keyuse_array);
...
        //使用“物化”优化半连接嵌套
        if (optimize_semijoin_nests_for_materialization(join))
                DBUG_RETURN(true);
        /* 选择多表连接算法（策略有两个，一是强制优化器使用用户指定的次序执行多表连接，二是采取贪婪穷尽式算法搜索最好的多表连接次序），进行多表连接的优化，可得到最优或较优的连接路径 */
        if (Optimize_table_order(thd, join, NULL).choose_table_order())
                DBUG_RETURN(true);
...
        if (join-＞decide_subquery_strategy()) //决定子查询的优化策略(EXISTS和materialization,二选一)
                DBUG_RETURN(true);
...
        if (join-＞get_best_combination()) //根据choose_table_order得到的最优路径生成查询执行计划
                DBUG_RETURN(true);
...
}
```

#3.comments
```cpp
/**
  Calculate best possible join order and initialize the join structure.

  @param  join          Join object that is populated with statistics data
  @param  tables_arg    List of tables that is referenced by this query 
  @param  conds         Where condition of query
  @param  keyuse_array[out] Populated with key_use information  
  @param  first_optimization True if first optimization of this query

  @return true if success, false if error

  @details
  Here is an overview of the logic of this function:

  - Initialize JOIN data structures and setup basic dependencies between tables.

  - Update dependencies based on join information.

  - Make key descriptions (update_ref_and_keys()).

  - Pull out semi-join tables based on table dependencies.

  - Extract tables with zero or one rows as const tables.

  - Read contents of const tables, substitute columns from these tables with
    actual data. Also keep track of empty tables vs. one-row tables. 

  - After const table extraction based on row count, more tables may
    have become functionally dependent. Extract these as const tables.

  - Add new sargable predicates based on retrieved const values.

  - Calculate number of rows to be retrieved from each table.

  - Calculate cost of potential semi-join materializations.

  - Calculate best possible join order based on available statistics.

  - Fill in remaining information for the generated join order.
*/
```