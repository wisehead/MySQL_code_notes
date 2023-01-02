#1.get_quick_record_count

```cpp
/*
get_quick_record_count函数通过调用test_quick_select函数可快速获取表上元组个数。

get_quick_record_count函数的实现代码如下：
*/
static ha_rows get_quick_record_count(THD *thd, SQL_SELECT *select,
                                              TABLE *table,
                                              const key_map *keys,ha_rows limit)
{
...
        if (select)
        {...
                if ((error=
                        select-＞test_quick_select(thd, *(key_map *)keys,(table_map) 0, limit, 0)) == 1)
...
        }
}
```

#2.caller

```cpp
对图13-25简单分析如下：
❏get_quick_record_count函数被make_join_statistics函数调用，获取关系的元组数。
❏get_quick_record_count函数调用SQL_SELECT类的test_quick_select方法获取关系的元组数。
```