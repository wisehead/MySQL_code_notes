#1.TianmuAttr::EvaluatePack_IsNoDelete

```
TianmuAttr::EvaluatePack_IsNoDelete
--pack = mit.GetCurPackrow(dim);
--&dpn(get_dpn(pack));
--if (dpn.numOfDeleted > 0) {
----//-
--else
----mit.NextPackrow();
```