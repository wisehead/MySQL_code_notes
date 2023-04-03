#1.ParameterizedFilter::UpdateMultiIndex

```
ParameterizedFilter::UpdateMultiIndex
--if (descriptors_.Size() < 1) 
----PrepareRoughMultiIndex
----ParameterizedFilter::FilterDeletedForSelectAll
--else
--auto &rcTables = table_->GetTables();
--for (uint tableIndex = 0; tableIndex < rcTables.size(); tableIndex++) {
----auto rcTable = rcTables[tableIndex];
----for (uint i = 0; i < descriptors_.Size(); i++) {
------Descriptor &desc = descriptors_[i];
------if ((desc.attr.vc && desc.attr.vc->GetVarMap().size() >= 1) &&
            // Use the tab object in VarMap to compare with the corresponding table_
            (desc.attr.vc->GetVarMap()[0].GetTabPtr().get() == rcTable) &&
            (desc.GetJoinType() == DescriptorJoinType::DT_NON_JOIN)) {
--------isVald = true;
----if (!isVald) {
------FilterDeletedByTable(rcTable, no_dims, tableIndex);
------no_dims++;
--ParameterizedFilter::SyntacticalDescriptorListPreprocessing
--// Prepare execution - rough set part
--for (uint i = 0; i < descriptors_.Size(); i++) {
----//do nothing
--PrepareRoughMultiIndex
--nonempty = RoughUpdateMultiIndex();  // calculate all rough conditions,
--PropagateRoughToMind
--for (uint i = 0; i < descriptors_.Size(); i++) {
----if (descriptors_[i].IsType_Join() || descriptors_[i].IsDelayed() || descriptors_[i].IsOuter() ||
        descriptors_[i].IsType_In() || descriptors_[i].IsType_Exists()) {
      (!descriptors_[i].IsDelayed()) ? no_of_join_conditions++ : no_of_delayed_conditions++;
--for (uint i = 0; i < descriptors_.Size(); i++) {
----if (descriptors_[i].attr.vc) {
------cur_dim = descriptors_[i].attr.vc->GetDim();
----// limit should be applied only for the last descriptor
----ApplyDescriptor(i, (desc_no != no_desc || no_of_delayed_conditions > 0 || no_of_join_conditions) ? -1 : limit);
----last_desc_dim = cur_dim;
--rough_mind_->UpdateReducedDimension();
--mind_->UpdateNumOfTuples();
--//更新VC中的行数，要求去重
--for (int i = 0; i < mind_->NumOfDimensions(); i++) {
----if (mind_->GetFilter(i))
------table_->SetVCDistinctVals(i, mind_->GetFilter(i)->NumOfOnes());  // distinct values - not more than the number of rows after WHERE

--rough_mind_->ClearLocalDescFilters();
--DescriptorJoinOrdering

--for (uint i = 0; i < descriptors_.Size(); i++) {
----PrepareJoiningStep(join_desc, descriptors_, i, *mind_);  // group together all join conditions for one step

--mind_->UpdateNumOfTuples();
```