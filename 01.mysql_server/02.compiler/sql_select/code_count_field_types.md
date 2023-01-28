#1.count_field_types

```
count_field_types
--while ((field=li++))
----Item::Type real_type= field->real_item()->type();
----if (real_type == Item::FIELD_ITEM)
------param->field_count++;

```