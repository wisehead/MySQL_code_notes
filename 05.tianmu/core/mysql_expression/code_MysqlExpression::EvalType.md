#1.MysqlExpression::EvalType

```
MysqlExpression::EvalType
--if (tv) {
----auto tianmufield_set = tianmu_fields_cache.begin();
----while (tianmufield_set != tianmu_fields_cache.end()) {
------auto it = tv->find(tianmufield_set->first);
------if (it != tv->end()) {
--------for (auto &tianmufield : tianmufield_set->second) {
----------fieldtype = it->second;
----------tianmufield->SetType(fieldtype);
------tianmufield_set++;
--switch (mysql_type) {
----case STRING_RESULT: 
------if ((item->type() != Item_tianmufield::get_tianmuitem_type() && item->field_type() == MYSQL_TYPE_TIME) ||
          (item->type() == Item_tianmufield::get_tianmuitem_type() &&
           static_cast<Item_tianmufield *>(item)->IsAggregation() == false && item->field_type() == MYSQL_TYPE_TIME))
        type = DataType(common::ColumnType::TIME, 17, 0, item->collation);
------else if ((item->type() != Item_tianmufield::get_tianmuitem_type() &&
                item->field_type() == MYSQL_TYPE_TIMESTAMP) ||
               (item->type() == Item_tianmufield::get_tianmuitem_type() &&
                static_cast<Item_tianmufield *>(item)->IsAggregation() == false &&
                item->field_type() == MYSQL_TYPE_TIMESTAMP))
        type = DataType(common::ColumnType::TIMESTAMP, 17, 0, item->collation);
------else if ((item->type() != Item_tianmufield::get_tianmuitem_type() && item->field_type() == MYSQL_TYPE_DATETIME) ||
               (item->type() == Item_tianmufield::get_tianmuitem_type() &&
                static_cast<Item_tianmufield *>(item)->IsAggregation() == false &&
                item->field_type() == MYSQL_TYPE_DATETIME))
        type = DataType(common::ColumnType::DATETIME, 17, 0, item->collation);
------else if ((item->type() != Item_tianmufield::get_tianmuitem_type() && item->field_type() == MYSQL_TYPE_DATE) ||
               (item->type() == Item_tianmufield::get_tianmuitem_type() &&
                static_cast<Item_tianmufield *>(item)->IsAggregation() == false &&
                item->field_type() == MYSQL_TYPE_DATE))
        type = DataType(common::ColumnType::DATE, 17, 0, item->collation);
------else
--------type =
            DataType(common::ColumnType::STRING,
                     (item->str_value.length() == 0) ? item->max_length
                                                     : (item->str_value.length() * item->collation.collation->mbmaxlen),
                     0, item->collation);
--return type;                     
```