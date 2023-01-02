#1.add_not_null_conds

```cpp
/*
前面我们提到了add_not_null_conds函数——为条件子句增加非空条件函数，目的是应用语义优化的技术，对SQL查询语句进一步优化。该函数为等式条件子句增加非空条件。但不是所有的等式条件子句都可以增加非空条件。非空条件是DDL语句为表增加的属性信息，包括因主键索引创建暗含的列值非空、列定义为非空约束等情况。

例如，对于以下的两表连接，SQL语句如下：
SELECT * FROM t1,t2 WHERE t2.key=t1.field;

上条SQL语句的查询优化过程中连接的对象（两个表）可以表达如下：
any-access(t1), ref(t2.key=t1.field)

上述表达式表达的含义如下：
访问t1表（any_access），引用（ref）了t2.key=t1.field这个条件。但因为t2表有索引列key，所以可以增加判断条件以便为整体的查询计划做优化。增加条件后的SQL查询的含义可如下：
SELECT * FROM t1,t2 WHERE t2.key=t1.field AND t1.field IS NOT NULL

t2.key=t1.field中t2.key列是一个存在主键索引的列，故key不可为NULL，所以根据等式，能够判定t1.field也不能为NULL，所以可以为SQL查询增加条件t1.field IS NOT NULL。

MySQL因为能够使用非空约束支持语义优化，所以MySQL有多处代码在收集列的非空信息。对于列约束为非NULL的情况，MySQL的代码处理方式总结如下。

❏update_ref_and_keys函数：收集了空值拒绝（null-rejecting）的情况（在Key_field::null_rejecting）。有利于进行外连接消除的优化（即明确了哪些列是非空的）。

❏add_key_part函数：保存收集到的空值拒绝信息到Key_use。

❏create_ref_for_key函数：复制空值拒绝信息到TABLE_REF。这种方式有利于表数据的快速访问。
❏
add_not_null_conds函数：增加x IS NOT NULL到连接树（JOIN_TAB）的成员上的join_tab-＞m_condition。这样有利于条件的判断，这是利用了语义优化技术对SQL进行优化。

add_not_null_conds函数的实现代码如下：
*/
static void add_not_null_conds(JOIN *join)
{
....
        for (uint i=join-＞const_tables ; i ＜ join-＞tables ; i++)//遍历连接树中除常量表外的每个表
        {
                JOIN_TAB *tab=join-＞join_tab+i;
                if ((tab-＞type == JT_REF || tab-＞type == JT_EQ_REF ||
                        tab-＞type == JT_REF_OR_NULL) &&
                        !tab-＞table-＞maybe_null) //不是所有的等式条件子句都可以增加非空条件
                {
                        for (uint keypart= 0; keypart ＜ tab-＞ref.key_parts; keypart++)//遍历表上的每个key
                        {
                                if (tab-＞ref.null_rejecting & (1 ＜＜ keypart))
                                {
...
                                        Item_field *not_null_item= (Item_field*)real;
                                        JOIN_TAB *referred_tab= not_null_item-＞field-＞table-＞reginfo.join_tab;
...
                                        referred_tab-＞and_with_condition(notnull, __LINE__); //为等式条件子句增加非空条件
                                }
                        }
                }
        }
        DBUG_VOID_RETURN;
}

```

#2.caller

```
add_not_null_conds函数被make_join_select函数调用，利用非NULL信息优化表达式。
```