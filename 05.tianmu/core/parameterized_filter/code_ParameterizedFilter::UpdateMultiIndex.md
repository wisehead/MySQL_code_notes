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
--// Prepare execution - rough set part
--for (uint i = 0; i < descriptors_.Size(); i++) {
----//do nothing
--PrepareRoughMultiIndex
--nonempty = RoughUpdateMultiIndex();  // calculate all rough conditions,
```