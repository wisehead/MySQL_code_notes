#1.Optimize_table_order::determine_search_depth

```cpp
/*
1.determine_search_depth，决定贪婪算法搜索的深度

determine_search_depth函数决定多表连接搜索空间的搜索深度（为greedy算法准备搜索深度，greedy_search函数递归调用自己，做深度优先遍历，逐层构建连接路径）。

determine_search_depth函数的table_count参数表示表的个数（要连接的单表的个数，不包括常量表）。join-＞tables表示的是所有表的个数，join-＞const_tables表示的是所有常量表的个数，所以join-＞tables减去join-＞const_tables就得到了可做多表连接的表的个数，因为常量表和其他表连接的花费几乎可以忽略不计。table_count参数和uint max_tables_for_exhaustive_opt变量决定了搜索深度，体现出了贪婪和穷尽两种思维方式。

代码如下：
*/

uint Optimize_table_order::determine_search_depth(uint search_depth, uint table_count)
{
        //如果指定深度,则使用指定值
        if (search_depth ＞ 0)
                return search_depth;
        const uint max_tables_for_exhaustive_opt= 7; //最大搜索深度定义为一个常数,值为7
        if (table_count ＜= max_tables_for_exhaustive_opt) /* 如果表的个数小于7,则使用表的个数多1做搜索的深度(表的个数不包括常量表,如果递归层次即搜索空间大于表的个数,则可以穷举遍历所有的连接情况,所以通过花费比较从中可以挑出最优的;否则,只能搜索部分情况,挑出的最优连接树可能是最优也可能是局部最优) */
                search_depth= table_count+1; //对表个数较少的情况使用穷举的思路
        else /* 如果表的个数大于7,则搜索深度最多为7,这意味着7个以上的表做连接,其连接的搜索深度最多只限于7层,这样搜索时间不会太多(如果深度过大,则搜索最优路径将耗费大量的时间),但按贪婪搜索算法得到的最优路径不一定是真正最优的 */
                search_depth= max_tables_for_exhaustive_opt; //对表个数较多的情况使用非穷举的思路
        return search_depth;
}

```