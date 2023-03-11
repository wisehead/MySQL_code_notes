#1.Query::FieldUnmysterify

```
Query::FieldUnmysterify
--if (item->type() == Item_tianmufield::get_tianmuitem_type()) {
--} else if (item->type() == Item::SUM_FUNC_ITEM) {  // min(k), max(k), count(), avg(k), sum(),
----Item *tmp_item = UnRef(is->get_arg(0));
----if (tmp_item->type() == Item::FIELD_ITEM)
------ifield = (Item_field *)tmp_item;
--} else if (item->type() == Item::FIELD_ITEM)
----ifield = (Item_field *)item;
--for (; it != it_end; it++) {
----if (!mysql_table->pos_in_table_list->is_view_or_derived()) {
------col = AttrID(field_num);
------return true;
```