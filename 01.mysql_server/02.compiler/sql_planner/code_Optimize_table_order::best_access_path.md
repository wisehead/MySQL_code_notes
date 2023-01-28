#1. Optimize_table_order::best_access_path

```
JOIN::optimize
make_join_statistics
--Optimize_table_order::choose_table_order
----Optimize_table_order::optimize_straight_join
------Optimize_table_order::best_access_path
```

#2.code flow
```cpp
/*
best_access_path函数用于估算指定的、将要连接到连接树的表的最佳访问路径（是ref、all、eq_ref等）和花费，并把最优的路径加入到局部连接最优路径中。

最终的多表连接路径，是由初始的简单表进行数据扫描的方式选择，然后进行两表连接形成临时的关系（两表连接形成临时的关系是一个初步的局部路径还没有得到最终包括所有表的路径），再然后到多表连接形成层数比两表连接多的局部路径，一直到所有可连接的表连接后形成最终的路径（形成最终的路径的方式有很多，生成查询执行计划就是找出连接路径中最优的一个连接方式，作为查询执行计划的生成依据）。在这个过程中，每一个环节涉及的对象都可以称为“路径”（局部最优QEP，也称局部查询执行计划），本函数就是估算入口参数JOIN_TAB*s加入路径的连接花费，并把新形成的路径的最小花费作为最优路径加入到更大一层的路径中，直至最后形成所有表的连接后的最优路径。

根据入口参数JOIN_TAB*s的不同，确定是给简单表做扫描估算还是给连接得到的中间表做访问花费估算。

局部路径和一个表进行连接，形成新的局部路径，被记录下来，作为下次连接的基础，这就是贪婪算法的精髓所在：通过greedy_search函数上一次连接得到的局部连接查询执行计划，一定是最优的，所以下一层才可能构造出本层最优的局部连接查询执行计划。

best_access_path函数的实现代码如下：
*/
void Optimize_table_order::best_access_path(
                           JOIN_TAB        *s, //将被连接的表(TABLE *table= s-＞table)
                           table_map remaining_tables, //没有被连接到连接树中的表
                           uint        idx, /* 表的连接位置(如果存在多表连接,则要确定每个表在连接路径上的连接位置即连接次序,存储于join-＞positions数组上) */
                           bool        disable_jbuf, //如果不使用连接缓存,值为TRUE
                           double        record_count, //局部查询计划估算的元组数(连接后的元组数)
                           POSITION        *pos, //表s的访问路径,即生成的新连接树是join-＞positions[idx]
                           POSITION        *loose_scan_pos) //表s使用loosescan的访问路径
{...
        /* 第一部分：检索索引
        尽可能使用索引完成对表连接的优化工作,尽量避免做全表扫描。
        对于指定的连接表(JOIN_TAB  *s)找出其具体的表(TABLE *table= s-＞table),遍历连接表上可以使用的keyuse(s-＞keyuse),找出在使用了key或keypart(利用单键索引或联合索引中的部分键值可以快速读取记录)与先前的局部最优连接路径进行连接的最小的情况,如代码中得到最小的记录数(tmp2)用作估算最小的扫描花费。最小值对应的情况就是最优的路径 */
        if (unlikely(s-＞keyuse != NULL))
        {...
                for (Key_use *keyuse=s-＞keyuse; keyuse-＞table == table; )//遍历表s上的索引
                {...
                        const uint key= keyuse-＞key;
                        /* 遍历索引键的子键(结合循环,分析prev_record_reads求解的意义),找出表上可用的索引(这个索引使得表s与局部最优查询执行计划连接后最优)*/
                        while (keyuse-＞table == table && keyuse-＞key == key)
                        {...
                                //找出每个子键的可访问的方式(如JT_REF_OR_NULL方式扫描)
                                for ( ; keyuse-＞table == table && keyuse-＞key == key &&
                                           keyuse-＞keypart == keypart ; ++keyuse)
                                {...
                                        //如果可用的索引键没有引用连接树前面的表,则这个索引键可能可用于本表
                                        if (!(remaining_tables & keyuse-＞used_tables) &&
                                                 !(ref_or_null_part && (keyuse-＞optimize &
                                                           KEY_OPTIMIZE_REF_OR_NULL)))
                                        {...
                                                // 获得idx参与的连接的局部查询计划的元组数,作为局部查询计划的元组数
                                                double tmp2= prev_record_reads(join, idx, (found_ref |
                                                                                                   keyuse-＞used_tables));
                                                if (tmp2 ＜ best_prev_record_reads) //保存最优值和最优值对应的索引键
                                                {
                                                        best_part_found_ref= keyuse-＞used_tables & ~join-＞const_table_map;
                                                        best_prev_record_reads= tmp2;
                                                }
...
                                        }
...
                                }
                                found_ref|= best_part_found_ref; //如果找到最优的可用引用,记录下来
                        } //while (keyuse-＞table...循环结束
...
                        if (ft_key){...}//特殊处理全文检索
                        else
                        {....
                                /*
                                 关键求解过程：
                                 1. 如果找到索引的全部键(用户使用了索引的全部键)
                                   1.1 等值计算
                                          tmp = prev_record_reads(join, idx, found_ref);
                                          records=1.0;
                                   1.2 非等值计算
                                          1.2.1 存在常量,格式为：file ＜op＞ 常量(不需要考虑其他对象)
                                                    if (table-＞quick_keys.is_set(key))
                                                          records= (double) table-＞quick_rows[key];
                                                    else
                                                                  records= (double) s-＞records/rec; quick_range couldn't use key! */
                                          1.2.2 非常量形式(需要考虑其他对象,即引用ref其他对象的列)
                                   1.3 如果能利用覆盖索引则利用覆盖索引(调用index_only_read_time方法)
                                 2. 如果找到索引的部分键(用户使用了索引的部分键)
                                   2.1 如果可以使用大部分键或唯一的键
                                          tmp= (previous record count) * (records / combination)
                                          处理了各种情况,如ref、ref_or_null等情况
                                   2.2 否则,不做额外处理
                                          tmp= best_time;
                                */
                                } /* not ft_key */
                                { //保存求解得到的最好的值
                                       const double idx_time= tmp + records * ROW_EVALUATE_COST;
                                       trace_access_idx.add("rows", records).add("cost", idx_time);
                                       if (idx_time ＜ best_time)
                                       {
                                               best_time= idx_time;
                                               best= tmp;
                                               best_records= records;
...
                                       }
                              }
...
                        } //结束对表s上的索引的遍历 for (Key_use *keyuse=s-＞keyuse;
                        records= best_records;
                        }//结束对索引的判断,if (unlikely(s-＞keyuse != NULL))
        //以上是根据存在的索引,找出对连接有用的信息。能索引扫描则不进行全表扫描
        //第二部分：利用索引,尽量避免使用全表扫描
...
        //ref访问方式如果比表扫描(或索引扫描或快速扫描)得到更少元组数
        //而且,ref访问方式的花费更小,则不用进行全表扫描
        if (!(records ＞= s-＞found_records || best ＞ s-＞read_time))
        {
                // "scan" means (full) index scan or (full) table scan.
...
                goto skip_table_scan;//跳过表扫描
        }
        //可以用使用了索引的范围扫描执行;
        //引用访问,可以用使用同样的带有相同或更多键部分的索引
        if ((s-＞quick && best_key && s-＞quick-＞index == best_key-＞key &&
                 best_max_key_part ＞= s-＞table-＞quick_key_parts[best_key-＞key]))
        {...
                goto skip_table_scan;//跳过表扫描
        }
...
        //多种情况,跳过表扫描
...
        //第三部分：全表扫描的情况,估算花费
        {...
                //启发式规则：如果有过滤条件,假设有25%的元组被过滤
                if (found_constraint)
                      rnd_records-= rnd_records/4;
                /* 启发式规则：快速估算法估算的元组数与从表上扫描到的元组树不同,则采取快速估算法得到的元组数。这个元组数更精确,其值来自储存引擎 */
                if (s-＞table-＞quick_condition_rows != s-＞found_records)
                      rnd_records= s-＞table-＞quick_condition_rows;
...
                tmp+= (s-＞records - rnd_records) * ROW_EVALUATE_COST; //CPU花费
...
        }
...
        //第四部分：保存获取到的最优值放置到入口参数POSITION *pos中
        pos-＞records_read= records;
        pos-＞read_time=        best;
        pos-＞key=                  best_key;
        pos-＞table=                s;
        pos-＞ref_depend_map= best_ref_depends_map;
        pos-＞loosescan_key= MAX_KEY;
        pos-＞use_join_buffer= best_uses_jbuf;
        loose_scan_opt.save_to_position(s, loose_scan_pos);
...
}

```

#3.caller
```
❏best_access_path方法被optimize_straight_join方法调用，完成用户指定表的连接次序的语句的查询计划生成，这只是生成访问路径，并没有为多表连接操作进行优化，通常需要用户保证SQL语句的连接效率。

❏best_access_path方法被best_extension_by_limited_search方法调用，完成查询优化引擎对SQl语句的查询计划生成。

❏调用best_access_path方法的其他3个方法都被best_extension_by_limited_search方法调用。
```
#4.comments

```cpp
/**
  Find the best access path for an extension of a partial execution
  plan and add this path to the plan.

  The function finds the best access path to table 's' from the passed
  partial plan where an access path is the general term for any means to
  access the data in 's'. An access path may use either an index or a scan,
  whichever is cheaper. The input partial plan is passed via the array
  'join->positions' of length 'idx'. The chosen access method for 's' and its
  cost are stored in 'join->positions[idx]'.

  @param s                the table to be joined by the function
  @param thd              thread for the connection that submitted the query
  @param remaining_tables set of tables not included in the partial plan yet.
  @param idx              the length of the partial plan
  @param disable_jbuf     TRUE<=> Don't use join buffering
  @param record_count     estimate for the number of records returned by the
                          partial plan
  @param[out] pos         Table access plan
  @param[out] loose_scan_pos  Table plan that uses loosescan, or set cost to 
                              DBL_MAX if not possible.
*/
```