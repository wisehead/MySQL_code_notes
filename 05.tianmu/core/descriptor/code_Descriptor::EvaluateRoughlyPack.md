#1.Descriptor::EvaluateRoughlyPack

```
Descriptor::EvaluateRoughlyPack
--if (IsType_OrTree())
    return tree->root->EvaluateRoughlyPack(mit);
--if (attr.vc /*&& !attr.vc->IsConst()*/)
----r = attr.vc->RoughCheck(mit, *this);
------SingleColumn::RoughCheckImpl
```