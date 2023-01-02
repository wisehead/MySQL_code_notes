#1.set_position

```cpp
/*
set_position函数用于在连接对象JOIN上的连接路径（join-＞positions）上保存常量表的信息。
set_position函数的实现代码如下：
*/
static void
set_position (JOIN *join, uint idx, JOIN_TAB *table, Key_use *key)
{
         //为join-＞positions[idx]上的各成员保存值
...
        join-＞positions[idx].records_read=1.0;        /* This is a const table */
...
        join-＞positions[idx].use_join_buffer= FALSE;
        //把常量表放到idx指定位置
        JOIN_TAB **pos=join-＞best_ref+idx+1;
        JOIN_TAB *next=join-＞best_ref[idx];
        for (;next != table ; pos++)
        {
                JOIN_TAB *tmp=pos[0];
                pos[0]=next;
                next=tmp;
        }
        join-＞best_ref[idx]=table;
}
```
