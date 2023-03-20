#1.ParameterizedFilter::FilterDeletedByTable

```
ParameterizedFilter::FilterDeletedByTable
--Descriptor desc(table_, no_dims);
--desc.op = common::Operator::O_EQ_ALL;
--desc.encoded = true;
--PhysicalColumn *phc = rcTable->GetColumn(firstColumn);
--vcolumn::SingleColumn *vc = new vcolumn::SingleColumn(phc, mind_, 0, 0, rcTable, tableIndex);
--vc->MarkUsedDims(dims);
--mind_->MarkInvolvedDimGroups(
      dims);  // create iterators on whole groups (important for multidimensional updatable iterators)
--MIUpdatingIterator mit(mind_, dims);
--desc.CopyDesCond(mit);
--vc->LockSourcePacks(mit);
--while (mit.IsValid()) {
----vc->EvaluatePack(mit, desc);
--vc->UnlockSourcePacks();
--mit.Commit();
```