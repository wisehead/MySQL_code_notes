#1.add_key_field

```cpp
/*
接下来分析add_key_fields函数调用的add_key_field函数，其用于确定某个索引上涉及的单个列。

如果一个索引有用，则通过add_key_field函数保存key（field、eq_func、value、and_level等）到key的数组（key_fields）。这表示在一个表上，有索引可以在涉及的列（field）上使用。

*/

static void  /* add_key_field函数把相关的信息保存在 key_fields数组中,即通过本函数为这个数组的各个元素赋值,所以本函数的语句体是多个赋值语句 */
add_key_field(KEY_FIELD **key_fields,uint and_level, Item_func *cond,
                               Field *field, bool eq_func, Item **value, uint num_values,
                               table_map usable_tables, SARGABLE_PARAM **sargables)
{
...
        /* Store possible eq field */
        (*key_fields)-＞field=                field;
        (*key_fields)-＞eq_func=        eq_func;
        (*key_fields)-＞val=                *value;
        (*key_fields)-＞level=                and_level;
        (*key_fields)-＞optimize=        exists_optimize;
        (*key_fields)-＞null_rejecting= ((cond-＞functype() == Item_func::EQ_FUNC ||
                     cond-＞functype() == Item_func::MULT_EQUAL_FUNC) &&
                     ((*value)-＞type() == Item::FIELD_ITEM) &&
                     ((Item_field*)*value)-＞field-＞maybe_null());
        (*key_fields)-＞cond_guard= NULL;
        (*key_fields)++;
}
```

#2.caller

```
❏add_key_field函数被add_key_fields和add_key_equal_fields函数调用。

❏add_key_equal_fields函数被add_key_fields函数调用。

❏add_key_fields函数被update_ref_and_keys函数调用。

❏update_ref_and_keys函数被make_join_statistics调用。

以上四种调用关系表明，make_join_statistics是为表确认可用索引的总的入口，make_join_statistics函数通过找出所有可用索引为求解最优查询计划做了铺垫。

```