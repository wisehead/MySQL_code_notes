#1.Optimize_table_order::check_interleaving_with_nj

```cpp
/*
check_interleaving_with_nj函数用于检查表tab是否可以加入局部连接次序序列中，如果可以加入，则记录表被加入的历史（记录到历史中的动作可以被backout_nj_state方法回滚掉）。

表嵌套连接和外连接限制了表的连接次序，所以多表连接需要满足如下原则。
❏外表优先：连接中，外表优先于内表（如左外连接，A LEFT JOIN B决定了外表A连接内表B，而不能交换连接次序为B JOIN A）。
❏交叉避免：在连接次序上，嵌套连接的表一定是一个连续的顺序（连续的顺序一定是不能被这个嵌套连接之外的表中断的）。
例如：SELECT * FROM t0 JOIN t1 LEFT JOIN (t2 JOIN t3) ON cond1;
连接次序t1t2t0t3是错误的，
正确的连接次序是t0t1(t2t3)，t1不可以和(t2t3)交换，(t2t3)构成一个连续的序列。

check_interleaving_with_nj函数的实现代码如下：
*/
bool Optimize_table_order::check_interleaving_with_nj(JOIN_TAB *tab) //tab为准备连接的表
{
        //tab表处于嵌套连接或外连接的限制中,不能加入局部连接次序序列中
        //准备连接的表tab已经被连接过了(不在cur_embedding_map中),则不能再连接了
        if (cur_embedding_map & ~tab-＞embedding_map)
            return true;
        const TABLE_LIST *next_emb= tab-＞table-＞pos_in_table_list-＞embedding;
        //如果不受限制(不存在嵌套连接或外连接制约),寻找tab表之后语义上再一次存在嵌套的情况
        for (; next_emb != emb_sjm_nest; next_emb= next_emb-＞embedding)
        {
                 //跳过连接嵌套的情况,外连接不忽略
                 if (!next_emb-＞join_cond())
                           continue;
                 next_emb-＞nested_join-＞nj_counter++; //嵌套连接层次探索,再进一层
                 cur_embedding_map |= next_emb-＞nested_join-＞nj_map; //把新探索到的嵌套层次记录到位图中
                 //某一层嵌套,嵌套的表数;某一层嵌套中已经探索的表数;如果不等,则意味着这个表可以被连接
                 if (next_emb-＞nested_join-＞nj_total != next_emb-＞nested_join-＞nj_counter)
                          break;
                 //否则,这个表已经连接过了,消除掉连接历史
                 cur_embedding_map &= ~next_emb-＞nested_join-＞nj_map; //记录表被加入的历史
        }
        return false;
}

```

#2.caller

```
由图13-34可知，check_interleaving_with_nj被4个方法调用，这4个方法都是构造连接树的方法，用于判断一个表是否可以被连接。
```