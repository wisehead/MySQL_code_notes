#1.Query::AddFields

```
Query::AddFields
--while (item) 
----OperationUnmysterify
----IsAggregationItem
----if ((IsFieldItem(item) || IsAggregationOverFieldItem(item)) && IsLocalColumn(item, tmp_table))
------AddColumnForPhysColumn(item, tmp_table, oper, distinct, false, item->item_name.ptr());
----else if (item->type() == Item::REF_ITEM) {
----else if (IsAggregationItem(item) && (((Item_sum *)item)->get_arg(0))->type() == Item::REF_ITEM &&
             (UnRef(((Item_sum *)item)->get_arg(0))->type() == Item_tianmufield::get_tianmuitem_type() ||
              (UnRef(((Item_sum *)item)->get_arg(0))->type() == Item_tianmufield::FIELD_ITEM)) &&
             IsLocalColumn(UnRef(((Item_sum *)item)->get_arg(0)), tmp_table))
----else if (IsAggregationItem(item)) {
------if (IsCountStar(item_sum)) {  // count(*) doesn't need any virtual column
------else
--------WrapMysqlExpression
```