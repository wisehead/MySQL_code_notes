#1.ParameterizedFilter::RoughUpdateMultiIndex
```
ParameterizedFilter::RoughUpdateMultiIndex
--// one-dimensional conditions
--if (!false_desc) {
----// init by previous values of mind_ (if any nontrivial)
----for (int i = 0; i < mind_->NumOfDimensions(); i++) {
------Filter *loc_f = mind_->GetFilter(i);
------rough_mind_->UpdateGlobalRoughFilter(i, loc_f);  // if the filter is nontrivial, then copy pack status
----for (uint i = 0; i < descriptors_.Size(); i++) {
------descriptors_[i].DimensionUsed(dims);
------int dim = dims.GetOneDim();
------common::RoughSetValue *rf = rough_mind_->GetLocalDescFilter(dim, i);
------descriptors_[i].ClearRoughValues(); 
------while (mit.IsValid()) 
--------int p = mit.GetCurPackrow(dim);
----------return cur_pack[dim]
--------if (p >= 0 && rf[p] != common::RoughSetValue::RS_NONE)
----------rf[p] = descriptors_[i].EvaluateRoughlyPack(mit);  // rough values are also accumulated inside
--------mit.NextPackrow();
------rough_mind_->UpdateGlobalRoughFilter(dim, i);  // update the filter using local information
------descriptors_[i].UpdateVCStatistics();
------descriptors_[i].SimplifyAfterRoughAccumulate();  // simplify tree if there is a
                                                       // roughly trivial leaf
--// Recalculate all multidimensional dependencies only if there are 1-dim
  // descriptors_ which can benefit from the projection
--if (DimsWith1dimFilters())
----RoughMakeProjections();                                                       
```

