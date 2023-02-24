#1.TianmuTable::Iterator::Initialize

```
TianmuTable::Iterator::Initialize
--for (auto const iter : attrs_) {
----if (iter) {
------TianmuAttr *attr = table->GetAttr(attr_id);
------attrs.push_back(attr);
------record.emplace_back(attr->ValuePrototype(false).Clone());
------values_fetchers.push_back(
          std::bind(&TianmuAttr::GetValueData, attr, std::placeholders::_1, std::ref(*record[attr_id]), false));
------
```