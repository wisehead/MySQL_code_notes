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


```