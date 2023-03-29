#1.Item_tianmufield::SetType

```
Item_tianmufield::SetType
--tianmu_type = t;
--switch (tianmu_type.valtype) {
----case DataType::ValueType::VT_STRING:
------ivalue = new Item_string("", 0, ifield->collation.collation, ifield->collation.derivation);
------break;
```