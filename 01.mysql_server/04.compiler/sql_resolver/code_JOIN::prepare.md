#1.JOIN::prepare

```cpp
/**
  Prepare of whole select (including sub queries in future).

  @todo
    Add check of calculation of GROUP functions and fields:
    SELECT COUNT(*)+table.col1 from table1;

  @retval
    -1   on error
  @retval
    0   on success
*/

JOIN::prepare
--
```

#2.完整函数

```cpp
int JOIN::prepare (TABLE_LIST *tables_init, //从SQL中解析出的被查询的所有表
                                uint wild_num, Item *conds_init, uint og_num,
                                ORDER *order_init, ORDER *group_init, //排序和分组子句
                                Item *having_init, //HAVING条件
                                SELECT_LEX *select_lex_arg, //语法查询树
                                SELECT_LEX_UNIT *unit_arg)
{...
        //初始化一些值并做权限检查(如调用check_access函数对权限进行检查)
        if (!(select_options & OPTION_SETUP_TABLES_DONE) &&
                    setup_tables_and_check_access(thd, &select_lex-＞context, join_list,
                                        tables_list, &select_lex-＞leaf_tables,
                                        FALSE, SELECT_ACL, SELECT_ACL))
                    DBUG_RETURN(-1);
...
        //setup_wild把查询语句中的“*”扩展为表上的所有列
        if (setup_wild(thd, tables_list, fields_list, &all_fields, wild_num))
                        DBUG_RETURN(-1);
        //setup_fields为列填充相应信息
        if (setup_fields(thd, ref_ptrs, fields_list, MARK_COLUMNS_READ, &all_fields, 1))
                        DBUG_RETURN(-1);
        /* setup_without_group调用setup_conds、setup_order、setup_group等函数,初始化条件、排序、分组操作各子句 */
        if (setup_without_group(thd, ref_ptrs, tables_list, select_lex-＞leaf_tables, fields_list,
                                        all_fields, &conds, order, group_list, &hidden_group_fields))
                        DBUG_RETURN(-1);
...
        if (select_lex-＞master_unit()-＞item && //子查询
                        select_lex-＞first_cond_optimization && //首次优化
                        !(thd-＞lex-＞context_analysis_only &
                        CONTEXT_ANALYSIS_ONLY_VIEW)) //非正常视图
        {
                        remove_redundant_subquery_clauses(select_lex); //去掉子查询冗余的部分
        }
/* 调用select_transformer处理子查询(Item_subselect *; subselect-＞select_transformer();) */
if (select_lex-＞master_unit()-＞item && //子查询
        !(thd-＞lex-＞context_analysis_only & CONTEXT_ANALYSIS_ONLY_VIEW) && //非正常视图
        !(select_options & SELECT_DESCRIBE))
{
        if (resolve_subquery(thd, this)) //优化IN/ANY/ALL/EXISTS式子查询
                        DBUG_RETURN(-1);
        }
        //调用split_sum_func、split_sum_func2等方法,统计ORDERBY、HAVING等子句中的sum操作
...
        //初始化连接操作(JOIN)相关信息
        count_field_types(&tmp_table_param, all_fields, 0);
...
}
```

#3.caller

![] (../images/prepare_caller.png)

