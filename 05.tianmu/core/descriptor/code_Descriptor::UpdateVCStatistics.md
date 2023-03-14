#1.Descriptor::UpdateVCStatistics

```
Descriptor::UpdateVCStatistics
--attr.vc->SetLocalNullsPossible(false);
--if ((attr.vc->Type().IsNumeric() || attr.vc->Type().Lookup()) && encoded)
----if (op == common::Operator::O_BETWEEN) {
------if (val1.vc)
--------v1 = val1.vc->RoughMin();
------if (val2.vc)
--------v2 = val2.vc->RoughMax(); 
----int v1_scale = val1.vc ? val1.vc->Type().GetScale() : 0;
    int v2_scale = val2.vc ? val2.vc->Type().GetScale() : v1_scale;
    types::TianmuNum v1_conv(v1, v1_scale);
    types::TianmuNum v2_conv(v2, v2_scale);
    if (v1 != common::NULL_VALUE_64 && v1 != common::PLUS_INF_64 && v1 != common::MINUS_INF_64)
      v1_conv = v1_conv.ToDecimal(attr.vc->Type().GetScale());
    if (v2 != common::NULL_VALUE_64 && v2 != common::PLUS_INF_64 && v2 != common::MINUS_INF_64)
      v2_conv = v2_conv.ToDecimal(attr.vc->Type().GetScale());
----attr.vc->SetLocalMinMax(v1_conv.ValueInt(), v2_conv.ValueInt());
```