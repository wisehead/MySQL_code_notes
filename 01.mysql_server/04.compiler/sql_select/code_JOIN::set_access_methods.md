#1.JOIN::set_access_methods

```cpp
/*
5.set_access_methods，为连接树中的每个表设置访问方式

set_access_methods函数为查询执行计划中的每个表、设置表数据的访问方法，如调用create_ref_for_key尽量利用索引等。

对表扫描时如果使用JT_ALL类型，则不应该有索引被使用，且应选择松散扫描半连接策略。

set_access_methods函数的实现代码如下：
*/
bool JOIN::set_access_methods()
{...
        //从0开始,循环遍历每一个表,包括常量表
        for (uint tableno= 0; tableno ＜ tables; tableno++)
        {
                JOIN_TAB *const tab= join_tab + tableno; //找出每个表
...
                // 基于贪婪搜索算法(greedy_search函数)的决策设置表的访问缓存的使用模式
                tab-＞use_join_cache= tab-＞position-＞use_join_buffer ?
                        JOIN_CACHE::ALG_BNL : JOIN_CACHE::ALG_NONE;
                if (tab-＞type == JT_CONST || tab-＞type == JT_SYSTEM)
                        continue;  // 常量表在make_join_statistics中已经被处理过,跳过不再处理
                Key_use *const keyuse= tab-＞position-＞key;
                if (!keyuse) //无索引可用,且非常量表,则设置“完全连接标志full_join”
                {
                        tab-＞type= JT_ALL;
                        if (tableno ＞ const_tables)
                              full_join= true;
                }
                else if (tab-＞position-＞sj_strategy == SJ_OPT_LOOSE_SCAN) //半连接策略使用了松散扫描
                {...
                        tab-＞type= JT_ALL;
                        tab-＞index= tab-＞position-＞loosescan_key;
                }
                else
                {       //其他情况,尽量利用索引
                        if (create_ref_for_key(this, tab, keyuse, tab-＞prefix_tables()))
                                DBUG_RETURN(true);
                }
        }
...
}

```

#2.caller

```
❏set_access_methods函数调用create_ref_for_key函数，使得表数据的获取尽量利用索引。

❏set_access_methods函数被JOIN.optimize函数调用，用以在多表连接结束阶段为每个单表设置访问方式。
```