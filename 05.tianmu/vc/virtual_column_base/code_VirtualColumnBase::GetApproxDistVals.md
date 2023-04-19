#1.VirtualColumnBase::GetApproxDistVals

```
VirtualColumnBase::GetApproxDistVals
--GetApproxDistValsImpl(incl_nulls, rough_mind);
----SingleColumn::GetApproxDistValsImpl
------col_->ApproxDistinctVals(incl_nulls, multi_index_->GetFilter(dim_), nullptr, multi_index_->NullsExist(dim_));
--------TianmuAttr::ApproxDistinctVals
```