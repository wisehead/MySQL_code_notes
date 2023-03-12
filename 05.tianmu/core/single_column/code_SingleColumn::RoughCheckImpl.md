#1.SingleColumn::RoughCheckImpl

```
SingleColumn::RoughCheckImpl
--if (d.val1.vc && static_cast<int>(d.val1.vc->IsSingleColumn()))
----sc = static_cast<SingleColumn *>(d.val1.vc);
--if (sc && sc->dim_ != dim_)  // Pack2Pack rough check
----return col_->RoughCheck(mit.GetCurPackrow(dim_), mit.GetCurPackrow(sc->dim_), d);
--else  // One-dim_ rough check
----return col_->RoughCheck(mit.GetCurPackrow(dim_), d, mit.NullsPossibleInPack(dim_));
------TianmuAttr::RoughCheck
```