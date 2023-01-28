#1.Optimize_table_order::best_extension_by_limited_search

```cpp
/*
下面介绍greedy_search函数中调用的子函数best_extension_by_limited_search——深度优先构造最优查询计划函数。

best_extension_by_limited_search函数通过深度优先和穷尽搜索多表连接的组合方式，确定多表连接的最佳路径，即形成了查询路径，最好的查询路径即是最好的查询计划。在确定了最好的连接路径时，计算本路径的花费。

best_extension_by_limited_search函数的实现代码如下：
*/
bool Optimize_table_order::best_extension_by_limited_search(
                table_map remaining_tables,/* 待连接的多个表(所有表的个数减去常量表的个数)。等待连接的表的集合,最初所有的简单表都在这个集合中,随着表连接的发生,连接过的表会在此集合中去除;注意这个参数本质上是一个位图,去掉表相当于从其上去掉表对应位置的位图上的标志 */
                //idx有多项含义：
                /* 1) 局部查询执行计划在join-＞positions中的长度(位置)。join-＞positions[idx]之前,存放的是常量表和已经存在的局部查询执行计划 */
                /* 2) best_extension_by_limited_search被深度优先方式调用,idx初始值是常量表的个数;与深度的值相呼应(idx递增,逐步递增N个;current_search_depth递减,逐步递减N个);idx逐步递增,表示在join-＞positions中逐步保存新的多表连接得到的局部最优查询执行计划;current_search_depth递减,best_extension_by_limited_search函数被递归调用,表明搜索空间有限,最多递归搜索search_depth次 */
                /* MySQL使用深度优先搜索算法构造查询计划,从树叶开始逐层向树顶构造,每个局部查询树的深度值为idx的值 */
             uint        idx,
             double        record_count, //“当前最好的局部查询计划”的元组数
             double        read_time, //“当前最好的局部查询计划”的花费
             uint            current_search_depth) /* 搜索深度,递减。路径搜索的深度,不可无限制地搜索下去,初始值是determine_search_depth函数确定的最大的搜索深度;在best_extension_by_limited_search函数自己递归调用的过程中,其值逐层递减表示靠近叶子层的查询树已经构造完毕,需要继续构造树的上层(远离叶子结点)*/
{...
          /* 遍历所有表,对每个表尝试做连接(遍历的表已经按一定规则排好序)*/
          /* join-＞best_ref的值,在make_join_statistics函数中被赋予初值,所有的叶子结点(基本表)排序后被置于join-＞best_ref数组,最前面的是常量表,不需要连接常量表,所以起始位置是join-＞best_ref + idx */
          for (JOIN_TAB **pos= join-＞best_ref + idx; *pos; pos++)
          {
                 JOIN_TAB *const s= *pos; //被连接的表(循环次数增加,将连接下一个表)
                 const table_map real_table_bit= s-＞table-＞map; //本次循环被连接的表的位图标识
...
                 //if的4个条件不满足,则跳过本表,寻找下一个满足连接条件的表进行连接
                 if ((remaining_tables & real_table_bit) && //本次要连接的表尚未被连接到路径中
                         !(eq_ref_extended & real_table_bit) && /* 连接表不是EQ_REF类型(如是EQ_REF类型,则因主键是唯一键的原因使得两表间的元组是1:1的关系)*/
                         !(remaining_tables & s-＞dependent) && /* 本次要连接的表与尚未被连接的表没有关联(如果有关联,则可能有外连接这样的依赖关系,则表间的次序需要考虑)*/
                        (!idx || !check_interleaving_with_nj(s)))
                {...
                        /*通过调用best_access_path函数得到局部查询执行计划的最优花费保存到join-＞positions[idx].records_read和join-＞positions[idx].read_time,然后计算当前最优花费。局部查询执行计划的最优花费是旧的局部查询计划连接上表s得到的新的局部查询执行计划*/
                        best_access_path(s, remaining_tables, idx, false, record_count,
                                position, &loose_scan_pos);
                        //计算表s连接到join-＞position[idx]中的花费：元组数、IO花费的时间
                        current_record_count= record_count * position-＞records_read;
                        current_read_time=        read_time
                                + position-＞read_time
                                + current_record_count * ROW_EVALUATE_COST;
                                position-＞set_prefix_costs(current_read_time, current_record_count);
                        /* 以上代码得到了当前表s和当前局部查询计划代表的临时表之间做连接产生的新的最优局部查询计划 */
                        if (has_sj)//如果存在半连接,则调用advance_sj_state函数对半连接优化
                        {
                                advance_sj_state(remaining_tables, s, idx,
                                        &current_record_count, &current_read_time, &loose_scan_pos);
                        }
                        else
                                position-＞no_semijoin();
                        //如果本次连接生成的新路径的花费更大,则调用backout_nj_state函数取消本次连接
                        if (current_read_time ＞= join-＞best_read)
                        {...
                                backout_nj_state(remaining_tables, s);
                                continue;
                        }
                        /* 启发式规则：剪枝掉一些没有优化前途的局部查询执行计划。可能会丢掉最优的查询执行计划。剪枝属于非穷举搜索范畴 */
                        if (prune_level == 1)//如果用户参数指定可作剪枝优化
                        {
                                //找出较小的元组数和时间花费
                                if (best_record_count ＞ current_record_count ||
                                       best_read_time ＞ current_read_time ||
                                       (idx == join-＞const_tables &&  // 's' is the first table in the QEP
                                       s-＞table == join-＞sort_by_table))
                                {
                                       if (best_record_count ＞= current_record_count &&
                                              best_read_time ＞= current_read_time &&
                                               /* TODO: What is the reasoning behind this condition? */
                                               (!(s-＞key_dependent & remaining_tables) ||
                                               position-＞records_read ＜ 2.0))
                                      {
                                               best_record_count= current_record_count;
                                               best_read_time= current_read_time;
                                       }
                                }
                                else //否则,本次连接生成的新路径的花费更大,则调用backout_nj_state函数取消本次连接
                                {...
                                        backout_nj_state(remaining_tables, s);
                                        continue;
                                }
                        }//剪枝优化结束
                        //去掉已经连接的表,余下的表是下次可被连接的表
                        const table_map remaining_tables_after= (remaining_tables & ~real_table_bit);
                        /* 当一个表被连接后,还有表没有被连接过且搜索深度还没有结束,则继续深度优先搜索,这样,可以深入下一层 */
                        if ((current_search_depth ＞ 1) && remaining_tables_after)
                        {
                                //启发式规则：为了避免对所有情况穷举
                                if (prune_level == 1 &&                //允许对查询计划执行剪枝优化
                                        position-＞key != NULL &&        //通过EQ_REF或REF方式连接
                                        position-＞records_read ＜= 1.0) //存在唯一键,所以连接的关系元组是1:1
                                {
                                         /* 只为第一个满足EQ_REF的表进行eq_ref_extension_by_limited_search函数确定的连接探索 */
                                         //eq_ref_extended之后不再为0,判断条件不再满足
                                         /* 以下代码要用除s表外的其他没有连接过的表和局部最优查询计划进行连接(通过递归调用本函数自己实现),探索其他的连接方式 */
                                         if (eq_ref_extended == (table_map)0)
                                         { ...
                                                 eq_ref_extended= real_table_bit |
                                                        eq_ref_extension_by_limited_search(
                                                               remaining_tables_after,
                                                               idx + 1, //递归调用时递增,表示用下一个表连接
                                                               current_record_count, current_read_time,
                                                               current_search_depth - 1);//递减,搜索空间减少不可无限递归
                                                 if (eq_ref_extended == ~(table_map)0)
                                                        DBUG_RETURN(true);          // Failed
                                              backout_nj_state(remaining_tables, s);
                                                /* 如果递归调用使得eq_ref_extended从0变为remaining_tables,则本循环不再需要进行下去,因为本次循环之后的所有的表,都满足了EQ_REF,都被前面eq_ref_extension_by_limited_search函数递归处理过了 */
                                                if (eq_ref_extended == remaining_tables)
                                                       goto done;
                                                   continue;
                                      }
                                      else  // Skip, as described above
                                      {...
                                              backout_nj_state(remaining_tables, s);
                                              continue;
                                      }
                              } // if (prunable...)
...
                              //对余下的表,深度优先做连接。递归调用自己
                              if (best_extension_by_limited_search(
                                          remaining_tables_after, //本次连接后余下的表进入下轮连接
                                          idx + 1, //加1表示下一个表连接到下一个位置
                                          current_record_count, current_read_time,
                                          current_search_depth - 1))//搜索深度递减
                                    DBUG_RETURN(true);
                      }
                      else  //if ((current_search_depth ＞ 1) && ...
                      {
                              //对连接后得到的局部查询树(保存到join-＞best_positions)做花费估算
                              consider_plan(idx, current_record_count, current_read_time, &trace_one_table);
...
                      }
                      backout_nj_state(remaining_tables, s);
                }//结束：if ((remaining_tables & real_table_bit) &&
        }//结束：for (JOIN_TAB **pos= join-＞best_ref + idx; *pos; pos++)
...
}
```

#2.caller

```
❏best_extension_by_limited_search方法被greedy_search方法调用。
❏best_extension_by_limited_search被eq_ref_extension_by_limited_search方法调用（这两个方法互为调用，形成递归）。
❏best_extension_by_limited_search被自己调用。
```