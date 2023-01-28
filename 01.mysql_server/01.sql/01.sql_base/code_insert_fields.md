#1.insert_fields

```
insert_fields
--for (TABLE_LIST *tables= (table_name ? context->table_list :
                            context->first_name_resolution_table);
       tables;
       tables= (table_name ? tables->next_local :
                tables->next_name_resolution_table)
       )
----thd->lex->used_tables|= tables->map();
----thd->lex->current_select()->select_list_tables|= tables->map();       
----field_iterator.set(tables);
----for (; !field_iterator.end_of_fields(); field_iterator.next())
------Item *const item= field_iterator.create_item(thd);
------if (item->type() == Item::FIELD_ITEM && tables->cacheable_table)
        ((Item_field *)item)->cached_table= tables;
------if (!found)
--------found= true;
--------it->replace(item); /* Replace '*' with the first found item. */
------thd->lex->used_tables|= item->used_tables();
------thd->lex->current_select()->select_list_tables|= item->used_tables();
------Field *const field= field_iterator.field();
------if (field)
--------field->table->mark_column_used(thd, field, thd->mark_used_columns);
```