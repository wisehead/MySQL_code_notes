#1.remove_redundant_subquery_clauses

```cpp
/*
remove_redundant_subquery_clauses函数用于去掉IN/ALL/ANY/EXISTS类型子查询中的
子查询语句的冗余子句（ORDERBY/DISTINCT/GROUPBY，GROUPBY不带有HAVING或聚集函数的操
作），因为ORDERBY/DISTINCT/GROUPBY等子句对IN/ALL/ANY/EXISTS类型子查询无意义，
是冗余的。

不处理简单的行子查询，即不对简单的行子查询进行去除查询中的冗余子句的操作，
格式如下：
SELECT * FROM t1 WHERE t1.a = (＜single row subquery＞);
SELECT a, (＜single row subquery) FROM t1;
*/

/*
另外，MySQL使用枚举定义了子查询的类型，如下：
enum subs_type {UNKNOWN_SUBS, SINGLEROW_SUBS, EXISTS_SUBS, IN_SUBS, ALL_SUBS, ANY_SUBS};
*/

Static /* subq_select_lex参数是子查询的语法树,所以操作对象是子查询对应的语句,非父查询对应的语句 */
void remove_redundant_subquery_clauses(st_select_lex *subq_select_lex)
{...
        bool order_with_sum_func= false; //初值为false
        for (ORDER *o= subq_select_lex-＞join-＞order; o != NULL; o= o-＞next)
                order_with_sum_func|= (*o-＞item)-＞with_sum_func; //如果有聚集函数,则值为true
        if (subq_select_lex-＞order_list.elements)
        {....
                if (!order_with_sum_func) //如果ORDERBY子句不包括聚集函数,则可以去掉ORDERBY子句
                        subq_select_lex-＞order_list.empty(); //清空排序操作的链表
        }
        //如果存在DISTINCT子句,则可以去掉DISTINCT子句
        if (subq_select_lex-＞options & SELECT_DISTINCT)
        {
                changelog|= REMOVE_DISTINCT;
                subq_select_lex-＞join-＞select_distinct= false;
                subq_select_lex-＞options&= ~SELECT_DISTINCT; //去掉DISTINCT子句的标识
        }
        //如果没有聚集函数且没有HAVING子句,则可以去掉GROUPBY子句
        if (subq_select_lex-＞group_list.elements &&
                !subq_select_lex-＞with_sum_func &&
                !subq_select_lex-＞join-＞having)
        {
                changelog|= REMOVE_GROUP;
                subq_select_lex-＞join-＞group_list= NULL;
                subq_select_lex-＞group_list.empty(); //清空分组操作的链表
        }
...
}

/*
由图13-3可知，remove_redundant_subquery_clauses函数被JOIN.prepare方法调用，
用于去除IN/ALL/ANY/EXISTS子查询类型中子查询语句中的ORDERBY/DISTINCT/GROUPBY操作。
*/
```