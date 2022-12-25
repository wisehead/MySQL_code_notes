#1.handle_select(查询优化器整体流程)
![优化器主干流程](./images/handle_select.png)

```
handle_select(){//第1层
        mysql_union(); //处理union操作
        mysql_select(){//第2层
                JOIN::prepare() {//第3层
                        remove_redundant_subquery_clauses();//去除子查询中的冗余子句
                        resolve_subquery(); //子查询优化
                }
                JOIN::optimize() {//第3层
                        flatten_subqueries(); //把子查询转换为半连接操作,只支持IN格式的子查询转为半连接
                        simplify_joins(); //消除外连接、消除嵌套连接
                        optimize_cond(…, conds, …); //优化WHERE子句
                        optimize_cond(…, having, …); //优化HAVING子句
                        opt_sum_query(); //优化count(*)、 min() 和 max(),适用于没有GROUPBY子句的情况
                        make_join_statistics(); //确定多表的连接路径;单表是多表的特例
                        {//第4层
                                update_ref_and_keys(); //获取索引信息,为快速定位数据、条件比较做准备
                                get_quick_record_count(); /*估算每个表中有多少元组可用(被循环调用计算多个表,包括了范围查询的代价计算) */
                                choose_plan()//多表连接以便得到最优的查询计划
                                {//第5层
                                        //挑选两种多表连接的方式之一做最优的多表连接,以便得到最优的查询计划
                                        optimize_straight_join(); //方式一：用户指定表的连接次序
                                        greedy_search(); //方式二：多表连接,贪婪算法
                                        {//第6层
                                                best_extension_by_limited_search(); //确定多表连接的最优查询执行计划
                                                {//第7层
                                                        best_access_path()//第8层,估算指定表的最优访问路径(也包括花费等)
                                                }//第7层结束
                                        }//第6层结束
                                }//第5层结束
                        }//第4层结束
                        ...
                        make_outerjoin_info(); //填充外连接的信息
                        ...
                        substitute_for_best_equal_field(); /* 循环遍历所有表达式,化简表达式(重复的等式能去掉则直接去掉,如：WHERE a=5 AND ((a=b AND b=c) OR c＞4) 的条件将变为：=(a) and (=(5,a,b,c) or c＞4))*/
                        ...
                        set_access_methods(); //设置每个表的访问方式
                        ...
                        make_join_select();  /* 用于执行各种不同情况的Join查询。该函数通过Join时,连接表的不同搜索方式(唯一索引查找、ref查找、快速范围查找、合并索引查找、全表扫描等不同方式),进行Join操作的处理 */
                        //优化DISTINCT谓词相关的情况,以下多行代码,处理不同的DISTINCT情况
                        ...
                        //创建临时表
                        //处理简单的IN子查询
                }//第3层结束,optimize()
                JOIN::exec() {//第3层
                        do_select(); //执行连接,输出结果到客户端
                }
        }//第2层结束,mysql_select()
}//第1层结束,handle_select()
```