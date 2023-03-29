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
```