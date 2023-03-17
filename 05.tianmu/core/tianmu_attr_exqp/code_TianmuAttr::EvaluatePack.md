#1.TianmuAttr::EvaluatePack

```
TianmuAttr::EvaluatePack
--if
----//nothing
--else if (GetPackType() == common::PackType::INT &&
             (d.op == common::Operator::O_BETWEEN || d.op == common::Operator::O_NOT_BETWEEN)) {
----if (!ATI::IsRealType(TypeName()))
------EvaluatePack_BetweenInt(mit, dim, d);
--------
```