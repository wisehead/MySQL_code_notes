#1.count_field_types

```
count_field_types
--while ((field=li++))
----Item::Type real_type= field->real_item()->type();
----if (real_type == Item::FIELD_ITEM)
------param->field_count++;
----else if (real_type == Item::SUM_FUNC_ITEM)
------if (! field->const_item())
--------Item_sum *sum_item=(Item_sum*) field->real_item();
--------if (!sum_item->depended_from() ||
            sum_item->depended_from() == select_lex)
----------if (!sum_item->quick_group)
------------param->quick_group=0;			// UDF SUM function
----------param->sum_func_count++;
----------for (uint i=0 ; i < sum_item->get_arg_count() ; i++)
------------if (sum_item->get_arg(i)->real_item()->type() == Item::FIELD_ITEM)
--------------param->field_count++;
--------param->func_count++;
----------
```