#1.JOIN::get_best_combination

```cpp
/*
2.get_best_combination，生成最终的多表连接的执行顺序

get_best_combination函数通过计算得到增加了物化半连接表的多表连接的执行顺序（存放于JOIN结构体的成员join_tab数组），并为其填充每个对象所需的信息（包括对于物化半连接表的半连接策略选择）。从形式上看，是拿出best_positions上的挑选好的连接次序构造JOIN_TAB结构。

最终join_tab数组中，形成一个有序的序列，表示了多表的连接次序。从前到后的顺序如下。

1）语义决定序列的主序：按连接的语义排序，如外连接中有常量表，则此常量表不能排在join_tab的最前面。
2）常规的主表（primary_tables）：普通的表，包括因物化操作生成的临时表。
3）非常规的主表（const_tables）：普通的表，但被检测到存在常量（类似常量表），包括因物化操作生成的临时表。
4）内部排序、分组操作的临时表（tmp_tables）：存在有排序、分组操作的表，通常是子查询的结果构成的临时表。
5）可能存在的空洞：在join_tab数组数组中，有一些位置可能是空缺的。
6）使用物化策略被半连接优化的表：最后是半连接操作中作为内表的物化了的表。

get_best_combination的实现代码如下：
*/
bool JOIN::get_best_combination()
{...
        //计算临时表的数目,最多限制使用两个临时表
        //计算临时表,是因为临时表在查询树上需要占据位置
        //在优化的过程中,一些操作需要创建临时表(如分组操作、DISTINCT操作)
        uint tmp_tables= (group_list ? 1 : 0) +
                                        (select_distinct ? 1 : 0) +
                                        (order ? 1 : 0) +
                                        (select_options & (SELECT_BIG_RESULT | OPTION_BUFFER_RESULT) ? 1 : 0) ;
        if (tmp_tables ＞ 2)
              tmp_tables= 2;
        /*
          使用可物化的嵌套半连接重新整理查询中表的位置。
          变化的内容是：
          1) 增加临时表结点
          2) 变化的结点：
                嵌套半连接 被替换为 物化的临时表作为一个“引用”
                物化的子查询包括的表 位置变换到 内表之后
        */
        //初始时,认为都是内连接
        uint outer_target= 0;  //所以,外连接的表位置是0
        //内连接表位置是所有表加临时表数,从大到小按表的关系减少(向左移动)
        uint inner_target= primary_tables + tmp_tables;
        uint sjm_nests= 0;//嵌套的半连接的个数
        //遍历best_positions上所有表,统计半连接表的个数
        for (uint tableno= 0; tableno ＜ primary_tables; )
        {
                //遇到需要半连接操作处理的表,sjm_nests计数,
                //第一个内表位置(inner_target)左移(减少)半连接涉及的表的个数大小的长度
                //跳过“半连接涉及的表的个数大小的长度”个表,遍历后续的表
                if (sj_is_materialize_strategy(best_positions[tableno].sj_strategy))
                {
                       sjm_nests++;
                       inner_target-= (best_positions[tableno].n_sj_tables - 1);
                       tableno+= best_positions[tableno].n_sj_tables;
                }
                else //非半连接相关的表,则向右(向前)移动一位
                       tableno++;
        }
        /* 除原先涉及的表外,因加入临时表、半连接物化表,为这些表构造“空间”;
             这个“空间”将是一个数组(JOIN_TAB)的形式;
             best_positions是一个线性平面的形式 */
        if (!(join_tab= new(thd-＞mem_root) JOIN_TAB[tables + sjm_nests + tmp_tables]))
                DBUG_RETURN(true);
        int sjm_index= tables;  // Number assigned to materialized temporary table
        int remaining_sjm_inner= 0;
        /* 新的空间生成后,要把数据填充到这个空间中,所以遍历所有的表,复制每个表到对应新位置(join_tab)中。依然要分类型,物化的半连接和普通表的处理方式不同 */
        for (uint tableno= 0; tableno ＜ tables; tableno++)
        {
                //处理物化的半连接
                if (sj_is_materialize_strategy(best_positions[tableno].sj_strategy))
                {...
                          POSITION *const pos_table= best_positions + tableno;
                          TABLE_LIST *const sj_nest= pos_table-＞table-＞emb_sj_nest;
                          //得到物化半连接对象涉及的内表
                          remaining_sjm_inner= pos_table-＞n_sj_tables;
                          //生成物化的半连接对象
                          Semijoin_mat_exec *const sjm_exec=
                                new (thd-＞mem_root) Semijoin_mat_exec(sj_nest,
                                           (pos_table-＞sj_strategy == SJ_OPT_MATERIALIZE_SCAN),
                                           remaining_sjm_inner, outer_target, inner_target);
                          if (!sjm_exec)
                                DBUG_RETURN(true);
                          //新生成的物化的半连接对象保存到连接树空间中的外连接应该存放的位置
                          (join_tab + outer_target)-＞sj_mat_exec= sjm_exec;
                          //新生成的物化的半连接对象创建“物化表”
                          if (setup_materialized_table(join_tab + outer_target, sjm_index,
                                pos_table, best_positions + sjm_index))
                                DBUG_RETURN(true);
                          map2table[sjm_exec-＞table-＞tablenr]= join_tab + outer_target;
                          outer_target++;
                            sjm_index++;
                }
                /* 如果物理半连接存在内表,则目标表指向内表的位置;否则指向外表的位置(意味着不存在物化半连接操作,表的地位都是相同的) */
                const uint target= (remaining_sjm_inner--) ＞ 0 ? inner_target++ : outer_target++;
                JOIN_TAB *const tab= join_tab + target;
...
        }
...
        set_semijoin_info();//设置半连接信息
        //在增加了物化的半连接表后,为其更新索引等信息
        if (update_equalities_for_sjm())
               DBUG_RETURN(true);
...
}

```

#2.caller

```
get_best_combination方法被make_join_statistics函数唯一调用。
```