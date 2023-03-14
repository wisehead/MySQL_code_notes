#1.VirtualColumnBase::SetLocalMinMax

```
VirtualColumnBase::SetLocalMinMax
--if (loc_min == common::NULL_VALUE_64)
    loc_min = common::MINUS_INF_64;
--if (loc_max == common::NULL_VALUE_64)
    loc_max = common::PLUS_INF_64;
--if (Type().IsFloat()) {
--else
----if (vc_min_val_ == common::NULL_VALUE_64 || loc_min > vc_min_val_)
------vc_min_val_ = loc_min;
----if (vc_max_val_ == common::NULL_VALUE_64 || loc_max < vc_max_val_)
------vc_max_val_ = loc_max;
```