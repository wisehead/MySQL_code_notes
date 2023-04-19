#1.GroupByWrapper::ApproxDistinctVals

```
GroupByWrapper::ApproxDistinctVals
--if (dist_vals[gr_a] == common::NULL_VALUE_64)
----dist_vals[gr_a] = virt_col[gr_a]->GetApproxDistVals(true);  // incl. nulls, because they may define a group
------VirtualColumnBase::GetApproxDistVals
--return dist_vals[gr_a];
```