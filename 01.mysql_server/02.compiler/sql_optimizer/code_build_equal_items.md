#0.code

```
build_equal_items
--if (cond) 
----build_equal_items_for_cond
----cond->update_used_tables()
------Item_equal::update_used_tables
----if (cond_type == Item::COND_ITEM &&
        down_cast<Item_cond *>(cond)->functype() == Item_func::COND_AND_FUNC)
      cond_equal= &down_cast<Item_cond_and *>(cond)->cond_equal;
----else if (cond_type == Item::FUNC_ITEM &&
         down_cast<Item_func *>(cond)->functype() == Item_func::MULT_EQUAL_FUNC)
------cond_equal= new COND_EQUAL;
------if (cond_equal == NULL)
        return true;
------cond_equal->current_level.push_back(down_cast<Item_equal *>(cond));
--if (join_list)
----while ((table= li++))
------if (table->join_cond_optim())
```

#1.build_equal_items_for_cond
```
build_equal_items_for_cond
--check_stack_overrun
--if (cond_type == Item::COND_ITEM)
--else if (cond->type() == Item::FUNC_ITEM)
----check_equality
------if (item->type() == Item::FUNC_ITEM &&
      (item_func= down_cast<Item_func *>(item))->functype() ==
      Item_func::EQ_FUNC)
--------Item *left_item= item_func->arguments()[0];
--------Item *right_item= item_func->arguments()[1];
--------check_simple_equality
----------if (left_item->type() == Item::FIELD_ITEM &&
      right_item->type() == Item::FIELD_ITEM &&
      (left_item_field= down_cast<Item_field *>(left_item)) &&
      (right_item_field= down_cast<Item_field *>(right_item)) &&
      !left_item_field->depended_from &&
      !right_item_field->depended_from)
------------......
----
```

#1.build_equal_items

```cpp
/*
build_equal_items函数用于过滤所有的条件表达式，调用build_equal_items_for_cond函数完成对条件表达式中相等项的合并。如(t1.a=t2.b AND t2.b＞5AND t1.a=t3.c)被合并为(=(t1.a，t2.b，t3.c)AND t2.b＞5)。

build_equal_items的实现代码如下：
*/
Item *build_equal_items(THD *thd, Item *cond, COND_EQUAL *inherited,
                                        bool do_inherit, List＜TABLE_LIST＞ *join_list,
                                        COND_EQUAL **cond_equal_ref)
{...
        if (cond) //调用build_equal_items_for_cond函数完成对条件表达式中相等项的合并
        {        cond= build_equal_items_for_cond(thd, cond, inherited);...  }
...
                if (join_list)
                {...
                        while ((table= li++))//遍历join_list上存在的表对象上的条件表达式on_expr
                        {
                                if (table-＞join_cond()) //如果表上存在连接条件，递归处理条件子句
                                {
                                        List＜TABLE_LIST＞ *nested_join_list= table-＞nested_join ?
                                                &table-＞nested_join-＞join_list : NULL;
...
                                        table-＞set_join_cond(build_equal_items(thd, table-＞join_cond(), //递归调用自己
                                                inherited, do_inherit, nested_join_list, &table-＞cond_equal));
                                }
                        }// while ((table= li++))遍历join_list结束
                }// if (join_list)结束
...
        }
}

```

#2.caller

```cpp
总的调用关系为optimize_cond→build_equal_items→build_equal_items_for_cond→check_equality。

```