#1.ParameterizedFilter::ApplyDescriptor

```
ParameterizedFilter::ApplyDescriptor
--Descriptor &desc = descriptors_[desc_number];
--desc.DimensionUsed(dims);
--mind_->MarkInvolvedDimGroups(dims);  // create iterators on whole groups (important for
                                       // multidimensional updatable iterators)
--if (no_dims == 1) {
----for (int i = 0; i < mind_->NumOfDimensions(); i++) {
------if (mind_->GetFilter(i))
--------one_dim = i;
--// "true" here means that we demand an existing local rough filter
--rf = rough_mind_->GetLocalDescFilter(one_dim, desc_number,true);  
--int packs_no = (int)((mind_->OrigSize(one_dim) + ((1 << mind_->ValueOfPower()) - 1)) >> mind_->ValueOfPower());
--int pack_all = rough_mind_->NumOfPacks(one_dim);
--int pack_some = 0;
--for (int b = 0; b < pack_all; b++) {
----if (rough_mind_->GetPackStatus(one_dim, b) != common::RoughSetValue::RS_NONE)
------pack_some++;
--desc.EvaluateOnIndex(mit, limit)
--int poolsize = ha_tianmu_engine_->query_thread_pool.size();
--if ((tianmu_sysvar_threadpoolsize > 0) && (packs_no / poolsize > 0) && !desc.IsType_Subquery() &&
        !desc.ExsitTmpTable()) 
--else
----while (mit.IsValid()) {
------if (rf && mit.GetCurPackrow(one_dim) >= 0)
--------cur_roughval = rf[mit.GetCurPackrow(one_dim)];
------if (cur_roughval == common::RoughSetValue::RS_NONE) {
          mit.ResetCurrentPack();
          mit.NextPackrow();
------} else if (cur_roughval == common::RoughSetValue::RS_ALL) {
          mit.NextPackrow();
------} else {
          // common::RoughSetValue::RS_SOME or common::RoughSetValue::RS_UNKNOWN
--------desc.EvaluatePack(mit);
```