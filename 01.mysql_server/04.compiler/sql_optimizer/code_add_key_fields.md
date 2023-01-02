#1.add_key_fields

```cpp
static void
add_key_fields (JOIN *join, Key_field **key_fields, uint *and_level,
                                  Item *cond, table_map usable_tables,
                                  SARGABLE_PARAM **sargables)
{
        if (cond-＞type() == Item_func::COND_ITEM)
        {
...
                /* 如果条件表达式是AND类型(如a AND b AND c),则递归调用自己遍历每个子条件(如a可以用d OR e OR f表示,故需要递归调用自己) */
                if (((Item_cond*) cond)-＞functype() == Item_func::COND_AND_FUNC)
                {
                        while ((item=li++))
                                add_key_fields(join, key_fields, and_level, item, usable_tables, sargables);
...
                }
                else //条件表达式非AND类型,则递归调用自己处理OR类型
                {...}
                return;
        } // if (cond-＞type() == Item_func::COND_ITEM) 结束
        /* 子查询的优化：处理一种子查询的情况,考虑之前的函数所进行的子查询优化(即考虑已经被下压到子查询的、被打包存入Item_func_trig_cond类的条件,其类型是TRIG_COND_FUNC,为这样条件上的列找出索引信息)*/
        {
                if (cond-＞type() == Item::FUNC_ITEM &&
                        ((Item_func*)cond)-＞functype() == Item_func::TRIG_COND_FUNC)
                {
                        Item *cond_arg= ((Item_func*)cond)-＞arguments()[0];
                        if (!join-＞group_list && !join-＞order && //查询语句无分组也无排序子句
                                join-＞unit-＞item &&
                                join-＞unit-＞item-＞substype()==Item_subselect::IN_SUBS && //子查询是IN类型的子查询
                                !join-＞unit-＞first_select()-＞next_select())
                        {
                                KEY_FIELD *save= *key_fields;
                                add_key_fields(join, key_fields, and_level, cond_arg, usable_tables, sargables);
...
                        }
                        return;
                }
        }//满足以上注释中说明的条件,才可以找其上是否有索引可以用来做优化
...
        switch (cond_func-＞select_optimize()) {
                case Item_func::OPTIMIZE_NONE:
                         break;
                case Item_func::OPTIMIZE_KEY:
                {
                         //化简BETWEEN操作：a BETWEEN low AND high化简为a ＞= low AND a ＜= high
                         if (cond_func-＞functype() == Item_func::BETWEEN){...}
                         // IN, NE
                         else if (is_local_field (cond_func-＞key_item()) &&
                                 !(cond_func-＞used_tables() & OUTER_REF_TABLE_BIT))
                        {...}
                }
                         break;
                case Item_func::OPTIMIZE_OP:
                case Item_func::OPTIMIZE_NULL:
                        /* 以上3种情况,需要调用add_key_equal_fields函数(add_key_equal_fields函数调用了add_key_field函数) */
                case Item_func::OPTIMIZE_EQUAL:
...
                        if (const_item)/* 处理field1=const的情况,这时,调用add_key_field查看是否有索引在field1上可用 */
                        {
                                while ((item= it++))
                                {
                                         add_key_field(key_fields, *and_level, cond_func, item-＞field,
                                                  TRUE, &const_item, 1, usable_tables, sargables);
                                }
                        }
                        else /* 处理field1=field2的情况,这时,调用add_key_field查看是否有索引在field1和field2上可用 */
                        {
...
                                  add_key_field(key_fields, *and_level, cond_func, field,
                                                  TRUE, (Item **) &item, 1, usable_tables, sargables);
...
                        }
                        break;
        }
}
```

#2.caller

```
update_ref_and_keys
```