#1.create_ref_for_key

```cpp
/*
3.create_ref_for_key，创建索引键对应的表的引用信息

create_ref_for_key函数首先为一个连接对象（函数入口参数j）建立一个查找元组的使用索引的访问引用；然后为入口参数KEYUSE*org_keyuse对应的每一个JOIN_TAB*j上的TABLE_REF ref赋值，故函数名中有create_ref的字样；最后根据情况为j-＞type修正其值，如j-＞type=JT_CONST。

create_ref_for_key函数的实现代码如下：
*/

bool create_ref_for_key (JOIN *join, JOIN_TAB *j, Key_use *org_keyuse,
                                                  table_map used_tables)
{...
        if (ftkey)//存在全文检索的索引,特殊处理
        {...}
        else /* 计算被使用的键长度供后续为j-＞ref.key_buff和j-＞ref.key_buff2分配空间使用(遍历keyinfo-＞key_part中的每个元素,求每个元素中store_length的和) */
        {...}
...
        //为j-＞ref上的元素赋值
        j-＞ref.key_parts=keyparts;
        j-＞ref.key_length=length;
        j-＞ref.key=(int) key;
...
        if (ftkey) {...}//存在全文检索的索引,特殊处理
        else
        {
                // Set up TABLE_REF based on chosen Key_use-s.
                for (uint part_no= 0 ; part_no ＜ keyparts ; part_no++)
                {...
                        //获得索引的信息
                        if (keyuse-＞val-＞type() == Item::FIELD_ITEM)
                        {
                               // Look up the most appropriate field to base the ref access on.
                               keyuse-＞val= get_best_field(static_cast＜Item_field *＞(keyuse-＞val), join-＞cond_equal);
                               keyuse-＞used_tables= keyuse-＞val-＞used_tables();
                        }
...
                        store_key* key= get_store_key(thd,
                               keyuse,join-＞const_table_map,
                               &keyinfo-＞key_part[part_no],
                               key_buff, maybe_null);
...
                        //有索引可用
                        if (keyuse-＞used_tables || thd-＞lex-＞describe)
                               j-＞ref.key_copy[part_no]= key;
                        else
                        {      //无索引可用,先备份索引信息
                               (void) key-＞copy();
                               if (key-＞null_key) //索引存在空值
                                      j-＞ref.key_copy[part_no]= key; // Reevaluate in JOIN::exec()
                               else
                                      j-＞ref.key_copy[part_no]= NULL;
                         }
                         //保存空值索引引用信息,供下面判断使用JT_REF_OR_NULL或JT_REF方式扫描表做准备
                         if ((keyuse-＞optimize & KEY_OPTIMIZE_REF_OR_NULL) && maybe_null)
                         {...null_ref_key= key_buff;...}
                         key_buff+=keyinfo-＞key_part[part_no].store_length;
                }
        } /* not ftkey */
...
        if (j-＞type == JT_CONST)
                j-＞table-＞const_table= 1;
        else if (((actual_key_flags(keyinfo) & (HA_NOSAME | HA_NULL_PART_KEY)) != HA_NOSAME) ||
                keyparts != actual_key_parts(keyinfo) || null_ref_key)
        {
                j-＞type= null_ref_key ? JT_REF_OR_NULL : JT_REF;
                j-＞ref.null_ref_key= null_ref_key;
        }
        else if (keyuse_uses_no_tables && !(table-＞file-＞ha_table_flags() & HA_BLOCK_CONST_TABLE))
        {
                //使用常量作为连接判断条件,如SELECT * FROM a LEFT JOIN b ON b.key=30
                j-＞type=JT_CONST;
        }
        else
                j-＞type=JT_EQ_REF;
}
```

#2.caller

```
❏宏FT_KEYPART被上图中的4个函数引用，标识的是全文检索对应的索引键，FT是FullText的简写。

❏从图中可以看出，create_ref_for_key函数被3个函数调用，make_join_statistics函数直接、间接地调用了create_ref_for_key函数，最终被JOIN.optimize函数调用。
```