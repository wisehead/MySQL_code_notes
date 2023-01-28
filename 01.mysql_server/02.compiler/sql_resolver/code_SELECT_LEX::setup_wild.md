#1.SELECT_LEX::setup_wild

```
SELECT_LEX::setup_wild
--while (with_wild && (item= it++))
----if (item->type() == Item::FIELD_ITEM &&
        (item_field= down_cast<Item_field *>(item)) &&
        item_field->is_asterisk())
------insert_fields(thd, item_field->context,
                          item_field->db_name, item_field->table_name,
                          &it, any_privileges)   
----all_fields.elements+= fields_list.elements - elem;
----with_wild--;
```