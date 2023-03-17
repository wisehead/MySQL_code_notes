#1.TianmuAttr::EvaluatePack_BetweenInt

```
TianmuAttr::EvaluatePack_BetweenInt
--int pack = mit.GetCurPackrow(dim);
--auto &dpn = get_dpn(pack);
--int64_t pv1 = d.val1.vc->GetValueInt64(mit);
--int64_t pv2 = d.val2.vc->GetValueInt64(mit);
--int64_t local_min = dpn.min_i;
--int64_t local_max = dpn.max_i;
--if (pv1 != common::MINUS_INF_64)
----pv1 = pv1 - local_min;
--else
----pv1 = 0;
--if (pv2 != common::PLUS_INF_64)  // encode from 0-level to 2-level
----pv2 = pv2 - local_min;
--else
----pv2 = local_max - local_min;
--if (local_min != local_max) {
----auto p = get_packN(pack);
----auto filter = mit.GetMultiIndex()->GetFilter(dim);
----if (tianmu_sysvar_filterevaluation_speedup && filter &&
        filter->NumOfOnes(pack) > static_cast<uint>(1 << (mit.GetPower() - 1))) {
------//nothing
----else
------if (d.op == common::Operator::O_BETWEEN && !mit.NullsPossibleInPack(dim) && dpn.numOfNulls == 0) {
--------do {
----------auto v = p->GetValInt(mit.GetCurInpack(dim));
----------if (pv1 > v || v > pv2)
------------mit.ResetCurrent();
----------++mit;
--------} while (mit.IsValid() && !mit.PackrowStarted());
```