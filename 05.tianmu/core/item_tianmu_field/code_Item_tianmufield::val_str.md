#1.Item_tianmufield::val_str

```
Item_tianmufield::val_str
--if (tianmu_type.valtype == DataType::ValueType::VT_STRING) {
----str->copy(buf->sp, buf->len, ifield->collation.collation);
```