#1.Optimize_table_order::greedy_search
```cpp
/*
2.greedy_search，多表连接的贪婪算法

greedy_search函数通过使用混杂了贪婪式[插图]和穷尽式[插图]

贪婪算法表现在：每一步搜索的结果总被认为是本次循环得到的最优的结果，并且作为了下次连接的依据；通过best_extension_by_limited_search方法的record_count和read_time参数的传递，总是累计前次连接的结果；通过join-＞positions[idx]存放的新连接的结果作为下次连接的前驱依据。

穷尽算法表现在：通过对best_extension_by_limited_search方法的调用，完成搜索深度的穷举搜索，搜索深度不递减到1，搜索循环不结束。

如果启用了剪枝优化[插图]的搜索方法，搜索表之间的各种组合以得到最优的查询计划。（MySQL中在best_extension_by_limited_search方法的代码中判断prune_level变量是否等于1），则不算做穷尽搜索。

多表连接的贪婪算法过程如下：

1）初始：给定一个只有N个简单表（greedy_search函数的remaining_tables参数表示的表的个数，等于N个表减去常量表的个数，即非常量表的个数）的没有查询计划（join-＞positions为空）的JOIN对象实例，join-＞best_positions为空，join-＞best_read的值为一个巨大值（逐步使用求解出的更小的值为其赋值，最后求得最小值即得到最优路径）。

2）中间过程：
①调用best_access_path求解当前表和局部最优路径连接的花费。
②递归调用best_extension_by_limited_search，对除当前表外的其他没有连接过的表和局部最优查询计划进行连接；搜索深度在递归调用自己时递减。
③经过以上两个步骤，所有可能的连接都搜索完成。
④循环执行中间过程的第一、第二步骤直至满足结束条件（循环使得N个简单表得到遍历）。

3）结束条件：构造的查询计划的搜索深度等于表的个数N，或者提前构造（深度优先遍历到最后一层把可连接的表用光了，没有可再连接的简单表了）出最优的查询计划树。

4）结果：得到最优的查询计划树存储在join-＞best_positions中，得到最优查询执行计划的花费存储在join-＞best_read中。

greedy_search函数的实现代码如下
*/
bool Optimize_table_order::greedy_search(table_map remaining_tables)
{...
        //跳过常量表,指向第一个要连接的表
        uint          idx= join-＞const_tables; // index into 'join-＞best_ref'
...
        do {
                    join-＞best_read= DBL_MAX;
                    join-＞best_rowcount= HA_POS_ERROR;
                    /* 得到“idx减去常量表”个表连接的最优局部查询执行计划,存放到join-＞best_positions[idx]。另外注意,这个函数将递归调用,采用深度优先的方式生成局部最优查询执行计划 */
                    if (best_extension_by_limited_search(remaining_tables, idx,
                                                                        record_count, read_time, search_depth))
                             DBUG_RETURN(true);
...
                    //最优的计划对应的位置
                    best_pos= join-＞best_positions[idx];
                    best_table= best_pos.table;
                /* join-＞positions[idx]可能被best_extension_by_limited_search函数在递归的过程中更改,所以在本次递归结束后改为原值备用 */
                join-＞positions[idx]= best_pos;
...
                //在join-＞best_ref中找到best_table的位置
                best_idx= idx;
                JOIN_TAB *pos= join-＞best_ref[best_idx];
                while (pos && best_table != pos)//找位置
                        pos= join-＞best_ref[++best_idx];
...
                //把最优JOIN_TAB放到找到的位置join-＞best_ref[idx]上
                memmove(join-＞best_ref + idx + 1, join-＞best_ref + idx, sizeof(JOIN_TAB*) * (best_idx - idx));
                join-＞best_ref[idx]= best_table;
                //计算连接后的元组数和时间花费
                //join-＞positions[idx]存放的是新连接的表在连接次序中应该处于的最好位置
                /* 这个最好的位置或者说这个位置标识的表best_table的元组数和之前的累计元组数的乘积,就是到best_table为止进行表连接的局部最优查询计划的元组数 */
                record_count*= join-＞positions[idx].records_read;
                //同上,累计时间花费是加和,表示的是IO花费
                read_time+= join-＞positions[idx].read_time + record_count * ROW_EVALUATE_COST;
                //计算得到最优局部路径的花费。每次循环,累计一次元组数和IO花费
                //元组数,是从初始值1累乘的结果(连接的语义做得是乘积动作)
                //花费,是从初始值0累加的结果,把每次新的连接花费加上,是IO花费
                record_count*= join-＞positions[idx].records_read; //通过连接操作可得到的元组数
                read_time+= join-＞positions[idx].read_time //单表读数据的花费,属于IO花费
                        + record_count * ROW_EVALUATE_COST; //计算连接的CPU花费
                //从待连接的表中,去掉已经被连接的表
                remaining_tables&= ~(best_table-＞table-＞map);
                --size_remain;
                ++idx; //指向下一个待连接的表
...
        } while (true); //进入下一次循环,直到得到贪婪算法认为的最优查询执行计划
}
```


#2.comments



```cpp
/**
  Find a good, possibly optimal, query execution plan (QEP) by a greedy search.

    The search procedure uses a hybrid greedy/exhaustive search with controlled
    exhaustiveness. The search is performed in N = card(remaining_tables)
    steps. Each step evaluates how promising is each of the unoptimized tables,
    selects the most promising table, and extends the current partial QEP with
    that table.  Currenly the most 'promising' table is the one with least
    expensive extension.\

    There are two extreme cases:
    -# When (card(remaining_tables) < search_depth), the estimate finds the
    best complete continuation of the partial QEP. This continuation can be
    used directly as a result of the search.
    -# When (search_depth == 1) the 'best_extension_by_limited_search'
    consideres the extension of the current QEP with each of the remaining
    unoptimized tables.

    All other cases are in-between these two extremes. Thus the parameter
    'search_depth' controlls the exhaustiveness of the search. The higher the
    value, the longer the optimizaton time and possibly the better the
    resulting plan. The lower the value, the fewer alternative plans are
    estimated, but the more likely to get a bad QEP.

    All intermediate and final results of the procedure are stored in 'join':
    - join->positions     : modified for every partial QEP that is explored
    - join->best_positions: modified for the current best complete QEP
    - join->best_read     : modified for the current best complete QEP
    - join->best_ref      : might be partially reordered

    The final optimal plan is stored in 'join->best_positions', and its
    corresponding cost in 'join->best_read'.

  @note
    The following pseudocode describes the algorithm of 'greedy_search':

    @code
    procedure greedy_search
    input: remaining_tables
    output: pplan;
    {
      pplan = <>;
      do {
        (t, a) = best_extension(pplan, remaining_tables);
        pplan = concat(pplan, (t, a));
        remaining_tables = remaining_tables - t;
      } while (remaining_tables != {})
      return pplan;
    }

  @endcode
    where 'best_extension' is a placeholder for a procedure that selects the
    most "promising" of all tables in 'remaining_tables'.
    Currently this estimate is performed by calling
    'best_extension_by_limited_search' to evaluate all extensions of the
    current QEP of size 'search_depth', thus the complexity of 'greedy_search'
    mainly depends on that of 'best_extension_by_limited_search'.

  @par
    If 'best_extension()' == 'best_extension_by_limited_search()', then the
    worst-case complexity of this algorithm is <=
    O(N*N^search_depth/search_depth). When serch_depth >= N, then the
    complexity of greedy_search is O(N!).
    'N' is the number of 'non eq_ref' tables + 'eq_ref groups' which normally
    are considerable less than total numbers of tables in the query.

  @par
    In the future, 'greedy_search' might be extended to support other
    implementations of 'best_extension'.

  @par
    @c search_depth from Optimize_table_order controls the exhaustiveness
    of the search, and @c prune_level controls the pruning heuristics that
    should be applied during search.

  @param remaining_tables set of tables not included into the partial plan yet

  @return false if successful, true if error
*/
```

